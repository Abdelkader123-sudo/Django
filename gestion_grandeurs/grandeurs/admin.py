from django.contrib import admin
from .models import Grandeur, Mesure


@admin.register(Grandeur)
class GrandeurAdmin(admin.ModelAdmin):
    list_display = ("id", "nom", "unite", "valeur_min", "valeur_max")


@admin.register(Mesure)
class MesureAdmin(admin.ModelAdmin):
    list_display = ("id", "grandeur", "valeur", "datePrise")
    list_filter = ("grandeur",)
    ordering = ("-datePrise",)