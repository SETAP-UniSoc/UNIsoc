from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Event
from .services import send_event_notifications

# @receiver(post_save, sender=Event)
# def event_created(sender, instance, created, **kwargs):
#     if created:
#         send_event_notifications(instance)