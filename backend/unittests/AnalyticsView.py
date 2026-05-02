from rest_framework.test import APITestCase
from django.contrib.auth.models import User
from django.utils import timezone
from authentication.models import Society, Membership, Event, EventAttendance
# adjust import path if needed

class AnalyticsViewTestCase(APITestCase):

    def setUp(self):
        # Admin user with a society
        self.admin_user = User.objects.create_user(username='admin', password='pass123', role='admin')
        self.society = Society.objects.create(name='Test Society', admin=self.admin)

        # Non-admin user
        self.regular_user = User.objects.create_user(
            username="regular", password="pass123", role="member"
        )

        self.url = "/analytics/"  #please check your references 

# --- Auth & permission tests ---

    def test_unauthenticated_returns_401(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 401)
   
   def test_non_admin_returns_403(self):
        self.client.login(username="regular", password="pass123")
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 403)
        self.assertEqual(response.data["error"], "Admins only")

    # --- Society not found ---

    def test_admin_without_society_returns_404(self):
        # Admin with no society assigned
        orphan_admin = User.objects.create_user(
            username="orphan", password="pass123", role="admin"
        )
        self.client.login(username="orphan", password="pass123") #orphan???
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.data["error"], "Society not found")

    # --- Invalid period ---

    def test_invalid_period_returns_400(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.get(self.url, {"period": "decade"})#do you know what a decade is? nvm we get it 
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Invalid period")

# --- Valid period tests ---

    def test_default_period_is_week(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.get(self.url)  # no period param
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["labels"]), 7)
        self.assertEqual(len(response.data["totals"]), 7)

    def test_period_week_returns_7_points(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.get(self.url, {"period": "week"})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["labels"]), 7)

def test_period_month_returns_30_points(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.get(self.url, {"period": "month"})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["labels"]), 30)

    def test_period_6months_returns_26_points(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.get(self.url, {"period": "6months"})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["labels"]), 26)
        def test_period_year_returns_12_points(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.get(self.url, {"period": "year"})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["labels"]), 12)

    # --- Response shape ---

    def test_response_contains_required_keys(self): #is this an invalid test case
        self.client.login(username="admin", password="pass123")
        response = self.client.get(self.url, {"period": "week"})
        self.assertEqual(response.status_code, 200)
        for key in ["labels", "totals", "live_count", "total_events", "events_stats", "most_popular"]:
            self.assertIn(key, response.data)
            # --- Live membership count ---

    def test_live_count_only_includes_active_members(self):
        self.client.login(username="admin", password="pass123")

        active_member = User.objects.create_user(username="active", password="pass")
        left_member = User.objects.create_user(username="left", password="pass")

        Membership.objects.create(society=self.society, user=active_member, joined_at=timezone.now())
        Membership.objects.create(society=self.society, user=left_member, joined_at=timezone.now(), left_at=timezone.now())

        response = self.client.get(self.url, {"period": "week"})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["live_count"], 1)  # only active_member
         # --- Events stats ---

    def test_total_events_count_is_correct(self):
        self.client.login(username="admin", password="pass123")
        Event.objects.create(title="Event 1", society=self.society, event_date=timezone.now())
        Event.objects.create(title="Event 2", society=self.society, event_date=timezone.now())
        response = self.client.get(self.url, {"period": "week"})
        self.assertEqual(response.data["total_events"], 2)

    def test_most_popular_event_is_correct(self):
        self.client.login(username="admin", password="pass123")

        event1 = Event.objects.create(title="Big Event", society=self.society, event_date=timezone.now())
        event2 = Event.objects.create(title="Small Event", society=self.society, event_date=timezone.now())

        user1 = User.objects.create_user(username="u1", password="pass")
        user2 = User.objects.create_user(username="u2", password="pass")# event1 has 2 attendees, event2 has 0
        EventAttendance.objects.create(event=event1, user=user1)
        EventAttendance.objects.create(event=event1, user=user2)

        response = self.client.get(self.url, {"period": "week"})
        self.assertEqual(response.data["most_popular"]["title"], "Big Event") # invalid test case? 
        self.assertEqual(response.data["most_popular"]["attendee_count"], 2)

    def test_most_popular_is_none_when_no_events(self):
        self.client.login(username="admin", password="pass123")
        response = self.client.get(self.url, {"period": "week"})
        self.assertIsNone(response.data["most_popular"])