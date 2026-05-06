from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import Event, Society, Membership, EventRSVP
from django.utils import timezone
from datetime import timedelta

User = get_user_model()


class JoinEventTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )

        self.token = Token.objects.create(user=self.user)

        self.society = Society.objects.create(name="Test Society")

        Membership.objects.create(
            user=self.user,
            society=self.society,
            role="member"
        )

        self.event = Event.objects.create(
            society=self.society,
            title="Test Event",
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=2),
            created_by=self.user,
            status="upcoming"
        )

        self.url = reverse("join-event", args=[self.event.id])

    def test_join_event_success(self):
        EventRSVP.objects.filter(user=self.user, event=self.event).delete()

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        print(response.data)  # 🔥 TEMP DEBUG (remove later)

        self.assertEqual(response.status_code, 200)

    def test_join_event_without_auth(self):
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, 401)

    def test_join_nonexistent_event(self):
        url = reverse("join-event", args=[999])

        response = self.client.post(
            url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 404)