from django.contrib.auth import get_user_model
from django.db.models import Q
from django.core.mail import send_mail
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from .models import NotificationPreference

User = get_user_model()

def authenticate_user(identifier, password):
    try:
        user = User.objects.get(
            Q(up_number=identifier) | Q(email=identifier)
        )
    except User.DoesNotExist:
        return None

    if user.check_password(password):
        return user

    return None

def send_event_notifications(event):
    prefs = NotificationPreference.objects.filter(
        society=event.society,
        notify_new_events=True
    )

    for pref in prefs:
        user = pref.user

        html_content = render_to_string(
            "emails/event_notification.html",
            {"event": event}
        )

        email = EmailMultiAlternatives(
            subject=f"New Event: {event.title}",
            body="A new event has been posted.",  # fallback text
            from_email="your_email@gmail.com",
            to=[user.email],
        )

        email.attach_alternative(html_content, "text/html")
        email.send()
        


