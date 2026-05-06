from django.urls import reverse
from rest_framework.test import APITestCase
from authentication.models import Society


class SearchSocietyTests(APITestCase):

    def setUp(self):
        Society.objects.create(name="Chess Club")
        Society.objects.create(name="Football Society")
        Society.objects.create(name="Art Club")

        self.url = reverse("society-search")

    def test_search_returns_matching_results(self):
        response = self.client.get(self.url, {"query": "Club"})

        self.assertEqual(response.status_code, 200)

        data = response.data
        if isinstance(data, dict) and "results" in data:
            data = data["results"]

        self.assertGreaterEqual(len(data), 2)

    def test_search_no_results(self):
        response = self.client.get(self.url, {"query": "Nonexistent"})

        self.assertEqual(response.status_code, 200)

        data = response.data
        if isinstance(data, dict) and "results" in data:
            data = data["results"]

        self.assertEqual(len(data), 0)

    def test_search_empty_query_returns_all(self):
        response = self.client.get(self.url)

        self.assertEqual(response.status_code, 200)

        data = response.data
        if isinstance(data, dict) and "results" in data:
            data = data["results"]

        # backend returns ALL societies when query is empty
        self.assertEqual(len(data), 3)