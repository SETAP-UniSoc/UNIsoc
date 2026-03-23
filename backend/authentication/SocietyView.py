from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Count
from .models import Society, Membership

class SocietyListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # get all active societies with member count
        societies = Society.objects.filter(is_active=True).annotate(
            member_count=Count('membership', filter=__import__('django.db.models', fromlist=['Q']).Q(membership__left_at__isnull=True))
        ).order_by('name')

        data = [{
            "id": s.id,
            "name": s.name,
            "category": s.category,
            "description": s.description,
            "member_count": s.member_count,
        } for s in societies]

        return Response(data)