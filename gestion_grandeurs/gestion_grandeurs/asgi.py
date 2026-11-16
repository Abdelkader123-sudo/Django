import os
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gestion_grandeurs.settings')
django_asgi_app = get_asgi_application()   # initialise Django en premier

from channels.routing import ProtocolTypeRouter, URLRouter
from mqtt_topics.consumers import MqttTopicsConsumer
from mqtt_topics.routing import websocket_urlpatterns

application = ProtocolTypeRouter({
    'http': django_asgi_app,
    'websocket': URLRouter(websocket_urlpatterns),
    'mqtt': MqttTopicsConsumer.as_asgi(),
})