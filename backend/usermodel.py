from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser): 
    up_number = models.CharField(max_length=20, unique=True)
    role = models.CharField(
        max_length=20,
        choices=[
            ('admin', 'Admin'),
            ('user', 'User'),
            ('technician', 'Technician')
        ]
    )

    USERNAME_FIELD = 'up_number'
    REQUIRED_FIELDS = []

