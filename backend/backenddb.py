
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

class Membership(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='memberships'
    )

    society = models.ForeignKey(
        Society,
        on_delete=models.CASCADE,
        related_name='members'
    )

    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'society')

    def __str__(self):
        return f"{self.user} in {self.society}"

class Event(models.Model):
    STATUS_CHOICES = [
        ('upcoming', 'Upcoming'),
        ('cancelled', 'Cancelled'),
        ('completed', 'Completed'),
    ]

    society = models.ForeignKey(
        Society,
        on_delete=models.CASCADE,
        related_name='events'
    )

    title = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    location = models.CharField(max_length=255, blank=True)

    start_time = models.DateTimeField()
    end_time = models.DateTimeField()

    capacity_limit = models.IntegerField(
        null=True,
        blank=True,
        validators=[MinValueValidator(1)]
    )

    created_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        related_name='created_events'
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='upcoming'
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        from django.core.exceptions import ValidationError
        if self.end_time <= self.start_time:
            raise ValidationError("End time must be after start time.")

    def __str__(self):
        return self.title


class EventRSVP(models.Model):
    RSVP_CHOICES = [
        ('attending', 'Attending'),
        ('not_attending', 'Not Attending'),
    ]

    event = models.ForeignKey(
        Event,
        on_delete=models.CASCADE,
        related_name='rsvps'
    )

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='event_rsvps'
    )

    rsvp_status = models.CharField(
        max_length=20,
        choices=RSVP_CHOICES,
        default='attending'
    )

    rsvp_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('event', 'user')

    def __str__(self):
        return f"{self.user} - {self.event}"

class NotificationPreference(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='notification_preferences'
    )

    society = models.ForeignKey(
        Society,
        on_delete=models.CASCADE
    )

    notify = models.BooleanField(default=True)

    class Meta:
        unique_together = ('user', 'society')

class Message(models.Model):
    society = models.ForeignKey(
        Society,
        on_delete=models.CASCADE,
        related_name='messages'
    )

    sender = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True
    )

    content = models.TextField()

    sent_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Message from {self.sender}"

class AuditLog(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    action = models.CharField(max_length=100)
    description = models.TextField(blank=True)

    logged_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.action

AUTH_USER_MODEL = 'Unisoc.User'

#run in terminal 
#python manage.py makemigrations
#python manage.py migrate
