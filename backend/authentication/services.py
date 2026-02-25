from django.contrib.auth import get_user_model
from django.db.models import Q

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


