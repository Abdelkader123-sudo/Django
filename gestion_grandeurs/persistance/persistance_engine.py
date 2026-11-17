import json

import firebase_admin
from asgiref.sync import sync_to_async
from django.apps import apps
from django.conf import settings
from django.utils.dateparse import parse_datetime
from firebase_admin import credentials, db

# ---------- Firebase : initialisation unique ----------
if not firebase_admin._apps:
    firebase_admin.initialize_app(
        credentials.Certificate(str(settings.BASE_DIR / "firebase_private_certif.json")),
        {"databaseURL": "https://gestion-grandeurs-a1802-default-rtdb.firebaseio.com"},
    )


# ---------- SQLite ----------
def _save_mesure(payload: str):
    Grandeur = apps.get_model("grandeurs", "Grandeur")
    Mesure = apps.get_model("grandeurs", "Mesure")

    data = json.loads(payload)

    grandeur, _ = Grandeur.objects.get_or_create(
        nom="Temperature",
        defaults={"unite": "°C", "valeur_min": -50, "valeur_max": 150},
    )
    Mesure.objects.create(
        valeur=float(data["valeur"]),
        datePrise=parse_datetime(data["date_prise"]),
        grandeur=grandeur,
    )
    print(f"Mesure enregistrée : {data}")


# ---------- Firebase Realtime Database ----------
def _save_firebase(payload: str):
    data = json.loads(payload)
    data["time"] = data.get("date_prise")
    db.reference("temperature").push(data)
    print(f"Firebase : mesure envoyée {data}")


# Versions asynchrones : "await persist_mesure(payload)"
persist_mesure = sync_to_async(_save_mesure)
persist_to_firebase = sync_to_async(_save_firebase)