from rest_framework.test import APITestCase
from django.contrib.auth.models import User
from django.utils import timezone
from authentication.models import Event, Society, EventRSVP
# adjust imports as needed

class EventListCreateViewTests(APITestCase):

    def setUp(self):
        self.admin = User.objects.create_user(username="admin", password="pass123")
        self.admin.role = "admin"
        self.admin.save()

        self.regular_user = User.objects.create_user(username="regular", password="pass123")

        self.society = Society.objects.create(name="Test Society", admin=self.admin)

        self.event = Event.objects.create(
            society=self.society,
            title="Test Event",
            description="A test event",
            location="Room 1",
            start_time=timezone.now() + timezone.timedelta(days=1),
            end_time=timezone.now() + timezone.timedelta(days=1, hours=2),
            created_by=self.admin
        )
 self.list_url = f"/societies/{self.society.id}/events/"  # adjust
        self.detail_url = f"/events/{self.event.id}/"            # adjust
        self.edit_url = f"/events/{self.event.id}/edit/"         # adjust

    # --- GET (list events) ---

    def test_unauthenticated_cannot_get_events(self):
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, 401)

    def test_get_events_returns_200(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, 200) def test_get_events_excludes_cancelled(self):
        self.client.login(username="admin", password="pass123")
        self.event.status = "cancelled"
        self.event.save()
        response = self.client.get(self.list_url)
        ids = [e["id"] for e in response.data]
        self.assertNotIn(self.event.id, ids)

    def test_get_events_returns_correct_fields(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, 200)
        event = response.data[0]
        for key in ["id", "title", "description", "location", "start_time", "end_time", "capacity_limit", "status", "attendee_count"]:
            self.assertIn(key, event)def test_attendee_count_only_counts_attending(self):
        self.client.login(username="admin", password="pass123")
        user1 = User.objects.create_user(username="u1", password="pass")
        user2 = User.objects.create_user(username="u2", password="pass")
        EventRSVP.objects.create(event=self.event, user=user1, rsvp_status="attending")
        EventRSVP.objects.create(event=self.event, user=user2, rsvp_status="declined")
        response = self.client.get(self.list_url)
        self.assertEqual(response.data[0]["attendee_count"], 1)

    # --- POST (create event) ---

    def test_unauthenticated_cannot_create_event(self):
        response = self.client.post(self.list_url, {})
        self.assertEqual(response.status_code, 401)

    def test_non_admin_cannot_create_event(self):
        self.client.login(username="regular", password="pass123")
        response = self.client.post(self.list_url, {"title": "New Event"})
        self.assertEqual(response.status_code, 403)def test_admin_can_create_event(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.post(self.list_url, {
            "title": "New Event",
            "start_time": timezone.now() + timezone.timedelta(days=2),
            "end_time": timezone.now() + timezone.timedelta(days=2, hours=1),
        }, format="json")
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["title"], "New Event")

    def test_create_event_invalid_society_returns_404(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.post("/societies/9999/events/", {"title": "X"}, format="json")
        self.assertEqual(response.status_code, 404)
class EventDetailViewTests(APITestCase):

    def setUp(self):
        self.admin = User.objects.create_user(username="admin", password="pass123")
        self.admin.role = "admin"
        self.admin.save()

        self.regular_user = User.objects.create_user(username="regular", password="pass123")

        self.society = Society.objects.create(name="Test Society", admin=self.admin)

        self.event = Event.objects.create(
            society=self.society,
            title="Test Event",
            start_time=timezone.now(),
            end_time=timezone.now() + timezone.timedelta(hours=1),
            created_by=self.admin
        )
        self.detail_url = f"/events/{self.event.id}/"  # adjust

    # --- DELETE ---

    def test_unauthenticated_cannot_delete(self):
        response = self.client.delete(self.detail_url)
        self.assertEqual(response.status_code, 401)

    def test_non_admin_cannot_delete(self):
        self.client.login(username="regular", password="pass123")
        response = self.client.delete(self.detail_url)
        self.assertEqual(response.status_code, 403)
 def test_admin_can_cancel_event(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.delete(self.detail_url)
        self.assertEqual(response.status_code, 200)
        self.event.refresh_from_db()
        self.assertEqual(self.event.status, "cancelled")  # soft delete check

    def test_delete_nonexistent_event_returns_404(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.delete("/events/9999/")
        self.assertEqual(response.status_code, 404)
class EventEditViewTests(APITestCase):

    def setUp(self):
        self.admin = User.objects.create_user(username="admin", password="pass123")
        self.admin.role = "admin"
        self.admin.save()

        self.regular_user = User.objects.create_user(username="regular", password="pass123")

        self.society = Society.objects.create(name="Test Society", admin=self.admin)

        self.event = Event.objects.create(
            society=self.society,
            title="Original Title",
            start_time=timezone.now(),
            end_time=timezone.now() + timezone.timedelta(hours=1),
            created_by=self.admin
        )
        self.edit_url = f"/events/{self.event.id}/edit/"  # adjust

    # --- PATCH ---

    def test_unauthenticated_cannot_edit(self):
        response = self.client.patch(self.edit_url, {}, format="json")
        self.assertEqual(response.status_code, 401)

    def test_non_admin_cannot_edit(self):
        self.client.login(username="regular", password="pass123")
        response = self.client.patch(self.edit_url, {"title": "Hacked"}, format="json")
        self.assertEqual(response.status_code, 403)

    def test_admin_can_edit_event(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.patch(self.edit_url, {"title": "Updated Title"}, format="json")
        self.assertEqual(response.status_code, 200)
        self.event.refresh_from_db()
        self.assertEqual(self.event.title, "Updated Title")def test_partial_edit_preserves_other_fields(self):
        self.client.login(username="admin", password="pass123")
        self.client.patch(self.edit_url, {"title": "New Title"}, format="json")
        self.event.refresh_from_db()
        self.assertEqual(self.event.location, "")  # unchanged fields stay the same

    def test_edit_nonexistent_event_returns_404(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.patch("/events/9999/edit/", {"title": "X"}, format="json")
        self.assertEqual(response.status_code, 404)