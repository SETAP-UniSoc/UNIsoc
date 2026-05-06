from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from django.utils import timezone
from datetime import timedelta

from authentication.models import Society, Event, Membership

User = get_user_model()

class MyEventsViewTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )   
        self.token = Token.objects.create(user=self.user)

        self.society = Society.objects.create(
            name="Test Society"
        )

        # user must be a member to see events
        self.membership = Membership.objects.create(
            user=self.user,
            society=self.society
        )

        self.event = Event.objects.create(
            title="Test Event",
            society=self.society,
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=2),
            created_by=self.user
        )

    def test_get_my_events_success(self):
        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

    def test_get_my_events_without_auth_fails(self):
        url = reverse("my-events")

        response = self.client.get(url)

        self.assertEqual(response.status_code, 401)

    def test_my_events_response_contains_events(self):
        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertTrue(len(response.data) > 0)

    def test_my_events_returns_correct_event_title(self):

        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data[0]["title"], "Test Event")


    def test_user_with_no_societies_gets_empty_list(self):

        user = User.objects.create_user(
            email="nomember@uni.ac.uk",
            password="Password123!"
        )

        token = Token.objects.create(user=user)

        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 0)


    def test_admin_gets_society_events(self):

        admin_user = User.objects.create_user(
            email="admin@uni.ac.uk",
            password="Password123!",
            role="admin"
        )

        admin_token = Token.objects.create(user=admin_user)

        admin_society = Society.objects.create(
            name="Admin Society",
            admin=admin_user
        )

        Event.objects.create(
            title="Admin Event",
            society=admin_society,
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=2),
            created_by=admin_user
        )

        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {admin_token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["title"], "Admin Event")


    def test_left_society_user_no_longer_sees_events(self):

        self.membership.left_at = timezone.now()
        self.membership.save()

        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 0)

    def test_multiple_events_are_returned(self):

        Event.objects.create(
            title="Second Event",
            society=self.society,
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=1),
            created_by=self.user
        )

        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 2)


    def test_events_from_other_societies_not_returned(self):

        other_society = Society.objects.create(
            name="Other Society"
        )

        Event.objects.create(
            title="Hidden Event",
            society=other_society,
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=1),
            created_by=self.user
        )

        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

        titles = [event["title"] for event in response.data]

        self.assertNotIn("Hidden Event", titles)


    def test_response_contains_event_fields(self):

        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

        event = response.data[0]

        self.assertIn("title", event)
        self.assertIn("start_time", event)
        self.assertIn("end_time", event)


    def test_user_only_sees_joined_society_events(self):

        joined_society = Society.objects.create(
            name="Joined Society"
        )

        Membership.objects.create(
            user=self.user,
            society=joined_society
        )

        Event.objects.create(
            title="Joined Society Event",
            society=joined_society,
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=1),
            created_by=self.user
        )

        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        titles = [event["title"] for event in response.data]

        self.assertIn("Joined Society Event", titles)