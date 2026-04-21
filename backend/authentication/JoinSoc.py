from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from .models import Society, Membership

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
        society=society
    )

        if not created:
            if membership.left_at is None:
                return Response({"message": "Already joined"}, status=200)
            else:
        # Rejoining
                membership.left_at = None
                membership.save()
                return Response({"message": "Rejoined successfully"}, status=200)
    
    #hi