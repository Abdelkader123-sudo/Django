import os
import sys
import logging
from pathlib import Path

import paho.mqtt.client as mqtt
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.core.management.base import BaseCommand

PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "gestion_grandeurs.settings")

import django

django.setup()

from persistance.persistance_engine import persist_mesure, persist_to_firebase

BROKER = "localhost"
PORT = 1883
TOPIC = "sensor/temperature"
GROUP_NAME = "sensor_temperature"
logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = "Écoute le topic MQTT et enregistre / diffuse les mesures"

    def handle(self, *args, **options):
        channel_layer = get_channel_layer()

        def on_connect(client, userdata, flags, rc):
            print("Connecté au broker, code :", rc, flush=True)
            if rc == 0:
                client.subscribe(TOPIC, qos=1)

        def on_message(client, userdata, msg):
            payload = msg.payload.decode("utf-8")
            print(f"[{msg.topic}] {payload}", flush=True)

            etapes = (
                ("SQLite", lambda: async_to_sync(persist_mesure)(payload)),
                ("Firebase", lambda: async_to_sync(persist_to_firebase)(payload)),
                ("Redis", lambda: async_to_sync(channel_layer.group_send)(
                    GROUP_NAME,
                    {"type": "sensor.temperature", "message": {"payload": payload}},
                )),
            )
            for nom, fonction in etapes:
                try:
                    fonction()
                    print(f"  OK {nom}", flush=True)
                except Exception:
                    logger.exception("Erreur %s", nom)

        client = mqtt.Client()
        client.on_connect = on_connect
        client.on_message = on_message
        client.connect(BROKER, PORT)

        try:
            client.loop_forever()
        except KeyboardInterrupt:
            client.disconnect()
            print("Arrêt.")


if __name__ == "__main__":
    Command().handle()