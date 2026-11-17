import asyncio
import logging

from channels.generic.websocket import AsyncWebsocketConsumer
from mqttasgi.consumers import MqttConsumer

from persistance.persistance_engine import persist_mesure, persist_to_firebase

TOPIC = "sensor/temperature"
GROUP_NAME = "sensor_temperature"
STEP_TIMEOUT = 5  # secondes max par étape
logger = logging.getLogger(__name__)


class MqttTopicsConsumer(MqttConsumer):
    """Reçoit les messages MQTT (lancé par la commande mqttasgi)."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # garde une référence aux tâches pour éviter qu'elles soient ramassées par le GC
        self._tasks = set()

    async def connect(self):
        print("Connexion au broker MQTT...")
        await self.subscribe(TOPIC, 0)
        print(f"Abonné au topic : {TOPIC}")

    async def receive(self, mqtt_message):
        topic = mqtt_message["topic"]
        payload = mqtt_message["payload"].decode("utf-8")
        print(f"[{topic}] {payload} (QoS {mqtt_message['qos']})", flush=True)

        # On ne bloque jamais receive() : le traitement part en tâche de fond
        task = asyncio.create_task(self._process(payload))
        self._tasks.add(task)
        task.add_done_callback(self._tasks.discard)

    async def _process(self, payload):
        # Les 3 étapes sont indépendantes : on les lance en parallèle
        await asyncio.gather(
            self._step("SQLite", persist_mesure(payload)),
            self._step("Firebase", persist_to_firebase(payload)),
            self._step(
                "Redis",
                self.channel_layer.group_send(
                    GROUP_NAME,
                    {"type": "sensor.temperature", "message": {"payload": payload}},
                ),
            ),
        )

    async def _step(self, nom, coro):
        try:
            await asyncio.wait_for(coro, STEP_TIMEOUT)
            print(f"  OK {nom}", flush=True)
        except asyncio.TimeoutError:
            print(f"  !! TIMEOUT {nom} (> {STEP_TIMEOUT}s)", flush=True)
        except Exception:
            logger.exception("Erreur %s", nom)

    async def disconnect(self):
        await self.unsubscribe(TOPIC)
        for task in list(self._tasks):
            task.cancel()


class DashboardConsumer(AsyncWebsocketConsumer):
    """WebSocket côté navigateur : relaie les mesures au tableau de bord."""

    async def connect(self):
        await self.channel_layer.group_add(GROUP_NAME, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(GROUP_NAME, self.channel_name)

    async def sensor_temperature(self, event):
        await self.send(text_data=event["message"]["payload"])