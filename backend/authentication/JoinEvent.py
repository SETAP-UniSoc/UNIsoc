from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from .models import EventAttendance, Society, Membership

class JoinSocietyView(APIView):
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

        membership, created = Membership.objects.get_or_create(
            user=user,
            society=society,
            defaults={"left_at": None}
        )

        # If membership already existed
        if not created:
            if membership.left_at is None:
                return Response(
                    {"message": "Already joined"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            else:
                # Rejoining
                membership.left_at = None
                membership.joined_at = timezone.now()
                membership.save()

                return Response(
                    {"message": "Rejoined successfully"},
                    status=status.HTTP_200_OK
                )
        attendee_count = EventAttendance.objects.filter(
            event__society=society, 
            left_at__isnull=True).count()
        return Response(
            {"message": "Successfully joined", "attendee_count": attendee_count},
            status=status.HTTP_201_CREATED
        )