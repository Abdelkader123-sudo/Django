import io
import json
from contextlib import redirect_stdout
from unittest.mock import AsyncMock, patch

from channels.layers import get_channel_layer
from channels.routing import URLRouter
from channels.testing import WebsocketCommunicator
from django.test import TestCase
from django.test import override_settings
from django.utils import timezone

from grandeurs.models import Mesure
from mqtt_topics.consumers import GROUP_NAME, MqttTopicsConsumer, TOPIC
from mqtt_topics.routing import websocket_urlpatterns


class MqttTopicsConsumerTests(TestCase):
    async def test_persists_and_displays_every_received_measurement(self):
        consumer = MqttTopicsConsumer()
        consumer.channel_layer = AsyncMock()
        payloads = [
            json.dumps(
                {"valeur": float(value), "date_prise": timezone.now().isoformat()}
            )
            for value in range(5)
        ]
        output = io.StringIO()

        with (
            patch(
                "mqtt_topics.consumers.persist_to_firebase",
                new_callable=AsyncMock,
            ),
            redirect_stdout(output),
        ):
            for payload in payloads:
                await consumer.receive(
                    {
                        "topic": TOPIC,
                        "payload": payload.encode("utf-8"),
                        "qos": 1,
                    }
                )

        self.assertEqual(await Mesure.objects.acount(), len(payloads))
        displayed_measurements = [
            line for line in output.getvalue().splitlines()
            if line.startswith(f"[{TOPIC}] ")
        ]
        self.assertEqual(len(displayed_measurements), len(payloads))

    async def test_subscribes_with_qos_one(self):
        consumer = MqttTopicsConsumer()

        with patch.object(consumer, "subscribe", new_callable=AsyncMock) as subscribe:
            await consumer.connect()

        subscribe.assert_awaited_once_with(TOPIC, 1)


@override_settings(
    CHANNEL_LAYERS={
        "default": {"BACKEND": "channels.layers.InMemoryChannelLayer"}
    }
)
class DashboardConsumerTests(TestCase):
    async def test_dashboard_receives_measurement_from_channel_group(self):
        communicator = WebsocketCommunicator(
            URLRouter(websocket_urlpatterns),
            "/ws/sensor/temperature/",
        )
        connected, _ = await communicator.connect()
        self.assertTrue(connected)

        payload = '{"valeur": 25.5, "date_prise": "2026-11-10T12:00:00+00:00"}'
        await get_channel_layer().group_send(
            GROUP_NAME,
            {
                "type": "sensor.temperature",
                "message": {"payload": payload},
            },
        )

        self.assertEqual(await communicator.receive_from(), payload)
        await communicator.disconnect()

    def test_dashboard_page_uses_matching_websocket_path(self):
        response = self.client.get("/")

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "/ws/sensor/temperature/")
