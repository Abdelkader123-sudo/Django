from django.urls import path

from mqtt_topics.consumers import DashboardConsumer

websocket_urlpatterns = [
    path("ws/sensor/temperature/", DashboardConsumer.as_asgi()),
]
