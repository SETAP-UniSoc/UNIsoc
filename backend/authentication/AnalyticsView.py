from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from datetime import timedelta
from django.utils import timezone
from django.db.models import Count
from django.db.models.functions import TruncDay
from .models import Society, Membership


class AnalyticsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, society_id):
        period = request.query_params.get("period", "year")

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response(
                {"error": "Society not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        now = timezone.now()

        period_map = {
            "year": 365,
            "6months": 180,
            "month": 30,
            "week": 7,
            "day": 1,
        }

        if period not in period_map:
            return Response(
                {"error": "Invalid period"},
                status=status.HTTP_400_BAD_REQUEST
            )

        start_date = now - timedelta(days=period_map[period])

        data = (
            Membership.objects
            .filter(society=society, joined_at__gte=start_date)
            .annotate(day=TruncDay('joined_at'))
            .values('day')
            .annotate(count=Count('id'))
            .order_by('day')
        )

        return Response(data)