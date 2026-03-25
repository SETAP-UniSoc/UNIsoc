from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth.models import User
from unittest.mock import patch # find out 

from authentication.models import Event, EventAttendance


class JoinEventViewTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(username="testuser", password="pass123")
        self.client.login(username="testuser", password="pass123")

        self.future_event = Event.objects.create(
            name="Future Event",
            event_date=timezone.now() + timezone.timedelta(days=1)
        )

        self.past_event = Event.objects.create(
            name="Past Event",
            event_date=timezone.now() - timezone.timedelta(days=1)
        )

        # Adjust this depending on your URL config
        self.join_url = lambda event_id: f"/events/{event_id}/join/"

    # 🔒 Authentication required
    def test_join_event_requires_authentication(self):
        self.client.logout()
        response = self.client.post(self.join_url(self.future_event.id))

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    # ❌ Event not found
    def test_join_event_not_found(self):
        response = self.client.post(self.join_url(999))

        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.data["error"], "Event not found")

    # ❌ Cannot join past event
    def test_join_past_event(self):
        response = self.client.post(self.join_url(self.past_event.id))

        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Event has already passed")

    # ✅ First time join
    def test_join_event_success(self):
        response = self.client.post(self.join_url(self.future_event.id))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["message"], "Joined event")
        self.assertEqual(response.data["attendee_count"], 1)

        self.assertTrue(
            EventAttendance.objects.filter(
                user=self.user,
                event=self.future_event,
                left_at__isnull=True
            ).exists()
        )

    # ⚠️ Already attending
    def test_join_event_already_attending(self):
        EventAttendance.objects.create(
            user=self.user,
            event=self.future_event,
            left_at=None
        )

        response = self.client.post(self.join_url(self.future_event.id))

        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["message"], "Already attending")

    # 🔄 Rejoin after leaving
    def test_rejoin_event_after_leaving(self):
        attendance = EventAttendance.objects.create(
            user=self.user,
            event=self.future_event,
            left_at=timezone.now()
        )

        response = self.client.post(self.join_url(self.future_event.id))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["message"], "Joined event")

        attendance.refresh_from_db()
        self.assertIsNone(attendance.left_at)
        self.assertIsNotNone(attendance.joined_at)

    # 🔢 Attendee count only counts active attendees
    def test_attendee_count_only_active(self):
        # Active attendee
        EventAttendance.objects.create(
            user=self.user,
            event=self.future_event,
            left_at=None
        )

        # Left attendee
        other_user = User.objects.create_user(username="user2", password="pass123")
        EventAttendance.objects.create(
            user=other_user,
            event=self.future_event,
            left_at=timezone.now()
        )

        new_user = User.objects.create_user(username="user3", password="pass123")
        self.client.login(username="user3", password="pass123")

        response = self.client.post(self.join_url(self.future_event.id))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["attendee_count"], 2)  # only active users