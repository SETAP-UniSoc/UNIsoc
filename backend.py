
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator


class User(AbstractUser):
    ROLE_CHOICES = [
        ('user', 'User'),
        ('admin', 'Admin'),
    ]

    up_number = models.CharField(
        max_length=20,
        unique=True,
        null=True,
        blank=True
    )

    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default='user'
    )

    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    # first_name, last_name, email, password

    def __str__(self):
        return self.username

class Society(models.Model):
    name = models.CharField(max_length=100, unique=True)
    category = models.CharField(max_length=50, blank=True)
    description = models.TextField(blank=True)

    is_active = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class SocietyAdmin(models.Model):
    ROLE_CHOICES = [
        ('president', 'President'),
        ('vice_president', 'Vice President'),
        ('treasurer', 'Treasurer'),
        ('moderator', 'Moderator'),
    ]

    society = models.ForeignKey(
        Society,
        on_delete=models.CASCADE,
        related_name='admins'
    )

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='admin_societies'
    )

    role = models.CharField(max_length=50, choices=ROLE_CHOICES)

    class Meta:
        unique_together = ('society', 'user')

    def __str__(self):
        return f"{self.user.username} - {self.role}"


class MembershipRequest(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE
    )

    society = models.ForeignKey(
        Society,
        on_delete=models.CASCADE
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )

    request_timestamp = models.DateTimeField(auto_now_add=True)
    approval_timestamp = models.DateTimeField(null=True, blank=True)

    class Meta:
        unique_together = ('user', 'society')

    def __str__(self):
        return f"{self.user} -> {self.society} ({self.status})"

