from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
    username = None  # remove default username

    up_number = models.CharField(max_length=20, unique=True)
    email = models.EmailField(unique=True)  # make email unique
    role = models.CharField(
        max_length=20,
        choices=[
            ('admin', 'Admin'),
            ('user', 'User'),
            ('technician', 'Technician')
        ],
        default='user'
    )

    USERNAME_FIELD = 'up_number'
    REQUIRED_FIELDS = []