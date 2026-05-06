try:
    from celery import shared_task  # type: ignore
except Exception:
    # Fallback no-op decorator when Celery isn't available (e.g. during linting or dev)
    def shared_task(func=None, **_kwargs):
        if func is None:
            def decorator(f):
                return f
            return decorator
        return func
from django.core.mail import send_mail

@shared_task
def send_join_event_email(user_email, event_title, society_name, start_time, location, description):
    subject = f"You're attending: {event_title}"

    message = f"""
    Hello,

    You have successfully joined an event!

    Event: {event_title}
    Society: {society_name}
    Date & Time: {start_time}
    Location: {location}

    Description:
    {description}

    See you there!
    """

    send_mail(
        subject=subject,
        message=message,
        from_email="no-reply@yoursite.com",
        recipient_list=[user_email],
        fail_silently=False,
    
    )

    print("✅ EMAIL SENT")