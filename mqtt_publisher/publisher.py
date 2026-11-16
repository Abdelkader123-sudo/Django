import json
import random
import time
from datetime import datetime, timezone

import paho.mqtt.client as mqtt

BROKER = "localhost"
PORT = 1883
TOPIC = "sensor/temperature"
INTERVALLE = 1        # secondes entre deux mesures
NB_MESURES = None     # None = envoi infini ; mets par exemple 100 pour s'arrêter après 100 mesures

# paho-mqtt 2.x
client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
# Si tu as paho-mqtt 1.x, remplace la ligne ci-dessus par : client = mqtt.Client()

client.connect(BROKER, PORT)
client.loop_start()

print("Publication en cours... (Ctrl+C pour arrêter)")

compteur = 0
try:
    while NB_MESURES is None or compteur < NB_MESURES:
        message = {
            "valeur": round(random.uniform(15, 35), 2),
            "date_prise": datetime.now(timezone.utc).isoformat(),
        }
        publication = client.publish(TOPIC, json.dumps(message), qos=1)
        publication.wait_for_publish()
        compteur += 1
        print(f"Publié n°{compteur} : {message}")
        time.sleep(INTERVALLE)
except KeyboardInterrupt:
    print("Arrêt du publisher.")
finally:
    client.loop_stop()
    client.disconnect()
    print(f"Total publié : {compteur} mesures")