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

    def get(self, request, society_id):

        if request.user.role != "admin":
            return Response({"error": "Admins only"}, status=403)

        period = request.query_params.get("period", "week")

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        now = timezone.now()

        if period == "week":
            start_date = now - timedelta(days=7)
            trunc_function = TruncDay

        elif period == "month":
            start_date = now - timedelta(days=30)
            trunc_function = TruncDay

        elif period == "6months":
            start_date = now - timedelta(days=180)
            trunc_function = TruncWeek

        elif period == "year":
            start_date = now - timedelta(days=365)
            trunc_function = TruncMonth

        else:
            return Response({"error": "Invalid period"}, status=400)

        # Get joins grouped properly
        joins = (
            Membership.objects
            .filter(society=society, joined_at__gte=start_date)
            .annotate(period=trunc_function('joined_at'))
            .values('period')
            .annotate(count=Count('id'))
            .order_by('period')
        )

        # Get leaves grouped properly
        leaves = (
            Membership.objects
            .filter(society=society, left_at__gte=start_date)
            .annotate(period=trunc_function('left_at'))
            .values('period')
            .annotate(count=Count('id'))
            .order_by('period')
        )

        return Response({
            "joins": list(joins),
            "leaves": list(leaves)
        })