from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from django.core.mail import send_mail
from django.utils import timezone
from datetime import timedelta

from .models import NotificationPreference, Society, Membership, Event


class NotificationView(APIView):
    permission_classes = [IsAuthenticated]

    # GET USER PREFERENCES
    def get(self, request):
        user = request.user
        preferences = NotificationPreference.objects.filter(user=user)

        data = []
        for pref in preferences:
            data.append({
                "society": pref.society.name,
                "event_notifications": pref.event_notifications
            })

        return Response(data)

    # UPDATE PREFERENCES 
    def post(self, request):
        user = request.user
        society_id = request.data.get("society_id")

        # safer boolean handling
        event_notifications = str(request.data.get("event_notifications")).lower() == "true"

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        if not Membership.objects.filter(user=user, society=society).exists():
            return Response({"error": "Not a member of this society"}, status=403)

        pref, created = NotificationPreference.objects.update_or_create(
            user=user,
            society=society,
            defaults={
                "event_notifications": event_notifications
            }
        )

        return Response({
            "message": "Notification preferences updated",
            "society": society.name,
            "event_notifications": pref.event_notifications
        })



def send_event_confirmation(user, event):
    """
    Send email when admin creates an event
    """

    # check preference
    if not NotificationPreference.objects.filter(
        user=user,
        society=event.society,
        event_notifications=True
    ).exists():
        return

    send_mail(
        subject="Event Created Successfully",
        message=f"""
Your event "{event.title}" has been created successfully.

Details:
Date: {event.date}
Location: {event.location}

You will receive a reminder 24 hours before the event.
""",
        from_email="noreply@yourapp.com",
        recipient_list=[user.email],
        fail_silently=False,
    )


def send_event_reminders():
    """
    Run this every 10–60 minutes using cron or Celery
    """

    now = timezone.now()
    upcoming = now + timedelta(hours=24)

    events = Event.objects.filter(date__range=(now, upcoming))

    for event in events:
        admins = Membership.objects.filter(
            society=event.society,
            role="admin"
        )

        for member in admins:
            user = member.user

            if not NotificationPreference.objects.filter(
                user=user,
                society=event.society,
                event_notifications=True
            ).exists():
                continue

            send_mail(
                subject="Reminder: Event in 24 Hours",
                message=f"""
Reminder: Your event "{event.title}" is happening in 24 hours.

Date: {event.date}
Location: {event.location}

If you need to cancel or make changes, please do so now.
""",
                from_email="noreply@yourapp.com",
                recipient_list=[user.email],
                fail_silently=False,
            )