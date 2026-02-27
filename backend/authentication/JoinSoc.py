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
            return Response(
                {"message": "Already joined"},
                status=status.HTTP_400_BAD_REQUEST
            )

        return Response(
            {"message": "Successfully joined"},
            status=status.HTTP_201_CREATED
        )