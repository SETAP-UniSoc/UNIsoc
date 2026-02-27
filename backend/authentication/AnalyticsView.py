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

        if request.user.role != "admin":
            return Response({"error": "Admins only"}, status=403)

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        now = timezone.now()
        start_week = now - timedelta(days=7)

        days = []
        totals = []

        current_total = Membership.objects.filter(
            society=society,
            joined_at__lte=start_week
        ).exclude(
            left_at__lte=start_week
        ).count()

        for i in range(7):
            day = start_week + timedelta(days=i)

            joins = Membership.objects.filter(
                society=society,
                joined_at__date=day.date()
            ).count()

            leaves = Membership.objects.filter(
                society=society,
                left_at__date=day.date()
            ).count()

            current_total = current_total + joins - leaves

            days.append(day.strftime("%a"))  # Mon, Tue, etc
            totals.append(current_total)

        return Response({
            "days": days,
            "totals": totals
        })