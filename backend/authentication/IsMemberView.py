# filepath: c:\Users\monfi\Documents\Software Engineering Theory And Practice\Setap UniSoc\UNIsoc\backend\authentication\IsMemberView.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from .models import Society, Membership  # adjust import paths if needed


class IsMemberView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, society_id):
        user = request.user

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response(
                {"error": "Society not found"},
                status=status.HTTP_404_NOT_FOUND,
            )

        is_member = Membership.objects.filter(
            user=user,
            society=society,
            left_at__isnull=True
        ).exists()

        return Response({"is_member": is_member}, status=status.HTTP_200_OK)