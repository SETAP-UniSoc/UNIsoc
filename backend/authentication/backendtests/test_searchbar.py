from django.urls import reverse
from rest_framework.test import APITestCase
from authentication.models import Society


class SearchSocietyTests(APITestCase):

    def setUp(self):
        # create societies
        Society.objects.create(name="Chess Club")
        Society.objects.create(name="Football Society")
        Society.objects.create(name="Art Club")

    def test_search_returns_matching_results(self):
        url = reverse("search")  # adjust if needed

        response = self.client.get(url, {"query": "Club"})

        self.assertEqual(response.status_code, 200)
        self.assertTrue(len(response.data) >= 2)

    def test_search_no_results(self):
        url = reverse("search")

        response = self.client.get(url, {"query": "Nonexistent"})

        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 0)

    def test_search_empty_query(self):
        url = reverse("search")

        response = self.client.get(url)

        self.assertEqual(response.status_code, 400)