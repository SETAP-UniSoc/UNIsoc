from django.contrib.auth import get_user_model
from django.db.models import Q
from django.core.mail import send_mail
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
        event_notifications=True
    )

    emails = [p.user.email for p in prefs]

    if emails:
        send_mail(
            subject=f"New Event: {event.title}",
            message=f"{event.description}\nLocation: {event.location}",
            from_email="your_email@gmail.com",
            recipient_list=emails,
        )


