
from rest_framework import serializers
from grandeurs.models import Mesure

class MesureSerializer(serializers.ModelSerializer):

    date_prise = serializers.DateTimeField(
        source="datePrise",
        read_only=True
    )

    grandeur_nom = serializers.CharField(
        source="grandeur.nom",
        read_only=True
    )

    unite = serializers.CharField(
        source="grandeur.unite",
        read_only=True
    )

    class Meta:
        model = Mesure

        fields = [
            'id',
            'valeur',
            'date_prise',
            'grandeur',
            'grandeur_nom',
            'unite'
        ]