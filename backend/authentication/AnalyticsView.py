from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from datetime import timedelta
from django.utils import timezone
from django.db.models import Count
from django.db.models.functions import (TruncDay, TruncWeek, TruncMonth)
from .models import Society, Membership



class AnalyticsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):

        if request.user.role != "admin":
            return Response({"error": "Admins only"}, status=403)

        period = request.query_params.get("period", "week")

        try:
            society = Society.objects.get(admin=request.user)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        now = timezone.now()

        # Decide grouping & range
        if period == "week":
            days_range = 7
            delta = timedelta(days=1)
            label_format = "%a"  # Mon Tue Wed
        elif period == "month":
            days_range = 30
            delta = timedelta(days=1)
            label_format = "%d %b"
        elif period == "6months":
            days_range = 26
            delta = timedelta(weeks=1)
            label_format = "Week %W"
        elif period == "year":
            days_range = 12
            delta = timedelta(days=30)
            label_format = "%b"
        else:
            return Response({"error": "Invalid period"}, status=400)

        start_date = now - (delta * days_range)

        labels = []
        totals = []

        current_date = start_date

        for _ in range(days_range):

            total = Membership.objects.filter(
                society=society,
                joined_at__lte=current_date
            ).exclude(
                left_at__lte=current_date
            ).count()

            labels.append(current_date.strftime(label_format))
            totals.append(total)

            current_date += delta

        return Response({
            "labels": labels,
            "totals": totals
        })