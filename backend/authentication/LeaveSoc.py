from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from .models import Society, Membership

class LeaveSocietyView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, society_id):

        user = request.user

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response(
                {"error": "Society not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        try:
            membership = Membership.objects.get(
                user=user,
                society=society,
                left_at__isnull=True   # Only active membership
            )
        except Membership.DoesNotExist:
            return Response(
                {"error": "You are not an active member"},
                status=status.HTTP_400_BAD_REQUEST
            )

        membership.left_at = membership.delete = timezone.now()
        membership.save()

        return Response(
            {"message": "Successfully left society"},
            status=status.HTTP_200_OK
        )