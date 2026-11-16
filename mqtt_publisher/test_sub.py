import paho.mqtt.client as mqtt

compteur = 0

def on_connect(client, userdata, flags, reason_code, properties):
    print("Connecté, code :", reason_code)
    client.subscribe("sensor/temperature", qos=0)

def on_message(client, userdata, msg):
    global compteur
    compteur += 1
    print(f"Reçu n°{compteur} : {msg.payload.decode()}")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.connect("localhost", 1883)
client.loop_forever()