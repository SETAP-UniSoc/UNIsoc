from rest_framework.test import APITestCase
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta
from authentication.models import Event, EventAttendance, Society

class LeaveEventViewTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(username="testuser", password="pass123")
        self.other_user = User.objects.create_user(username="other", password="pass123")
        self.admin = User.objects.create_user(username="admin", password="pass123")
        self.society = Society.objects.create(name="Test Society", admin=self.admin)

        self.event = Event.objects.create(
            society=self.society,
            title="Test Event",
            event_date=timezone.now() + timedelta(days=1)
        )

        self.url = lambda event_id: f"/events/{event_id}/leave/"  # adjust

    # --- Auth ---

    def test_unauthenticated_returns_401(self):
        response = self.client.post(self.url(self.event.id))
        self.assertEqual(response.status_code, 401)

    # --- Not attending ---

    def test_cannot_leave_event_not_joined(self):
        self.client.login(username="testuser", password="pass123")
        response = self.client.post(self.url(self.event.id))
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Not attending this event")

    def test_cannot_leave_event_already_left(self):
        self.client.login(username="testuser", password="pass123")
        EventAttendance.objects.create(
            user=self.user,
            event=self.event,
            left_at=timezone.now() - timedelta(hours=1)  # already left
        )
        response = self.client.post(self.url(self.event.id))
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Not attending this event")

    def test_nonexistent_event_returns_400(self):
        self.client.login(username="testuser", password="pass123")
        response = self.client.post(self.url(9999))
        self.assertEqual(response.status_code, 400)

    # --- Leaving ---

    def test_can_leave_event(self):
        self.client.login(username="testuser", password="pass123")
        EventAttendance.objects.create(
            user=self.user,
            event=self.event,
            left_at=None
        )
        response = self.client.post(self.url(self.event.id))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["message"], "Left event successfully")

    def test_leaving_sets_left_at_in_db(self):
        self.client.login(username="testuser", password="pass123")
        attendance = EventAttendance.objects.create(
            user=self.user,
            event=self.event,
            left_at=None
        )
        self.client.post(self.url(self.event.id))
        attendance.refresh_from_db()
        self.assertIsNotNone(attendance.left_at)

    def test_leaving_does_not_delete_attendance_record(self):
        self.client.login(username="testuser", password="pass123")
        EventAttendance.objects.create(
            user=self.user,
            event=self.event,
            left_at=None
        )
        self.client.post(self.url(self.event.id))
        self.assertTrue(EventAttendance.objects.filter(
            user=self.user,
            event=self.event
        ).exists())

    # --- Other users unaffected ---

    def test_leaving_does_not_affect_other_users_attendance(self):
        self.client.login(username="testuser", password="pass123")
        EventAttendance.objects.create(user=self.user, event=self.event, left_at=None)
        EventAttendance.objects.create(user=self.other_user, event=self.event, left_at=None)
        self.client.post(self.url(self.event.id))
        other_attendance = EventAttendance.objects.get(user=self.other_user, event=self.event)
        self.assertIsNone(other_attendance.left_at)