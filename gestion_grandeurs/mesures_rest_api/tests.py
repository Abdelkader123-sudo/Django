from datetime import timedelta

from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APITestCase

from grandeurs.models import Grandeur, Mesure


class MesureListAPITests(APITestCase):
    def test_filters_by_date_range_and_serializes_date_prise(self):
        grandeur = Grandeur.objects.create(
            nom="Temperature",
            unite="C",
            valeur_min=0,
            valeur_max=100,
        )
        now = timezone.now()
        included = Mesure.objects.create(
            grandeur=grandeur,
            valeur=20,
            datePrise=now,
        )
        Mesure.objects.create(
            grandeur=grandeur,
            valeur=10,
            datePrise=now - timedelta(days=1),
        )

        response = self.client.get(
            reverse("mesures-list"),
            {
                "grandeur": grandeur.pk,
                "start": (now - timedelta(minutes=1)).isoformat(),
                "end": (now + timedelta(minutes=1)).isoformat(),
            },
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual([item["id"] for item in response.data], [included.pk])
        self.assertIn("date_prise", response.data[0])
