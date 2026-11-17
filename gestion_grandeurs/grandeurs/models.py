from django.db import models

class Grandeur(models.Model):
    nom = models.CharField(max_length=60)
    unite = models.CharField(max_length=30)
    valeur_min =models.FloatField()
    valeur_max=models.FloatField()

class Mesure(models.Model):
    valeur = models.FloatField()
    datePrise = models.DateTimeField()
    grandeur = models.ForeignKey(Grandeur, on_delete=models.CASCADE)
    