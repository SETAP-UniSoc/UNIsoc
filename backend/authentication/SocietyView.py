from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Count, Q
from .models import Society, Membership


class SocietyListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        societies = Society.objects.filter(is_active=True).annotate(
            member_count=Count(
                'membership',
                filter=Q(membership__left_at__isnull=True)
            )
        ).order_by('name')

        data = [{
            "id": s.id,
            "name": s.name,
            "category": s.category,
            "description": s.description,
            "member_count": s.member_count,
        } for s in societies]

        return Response(data)


class SocietyDetailView(APIView):
    permission_classes = [IsAuthenticated]

    # GET society details — used by both admin and user society page
    def get(self, request, society_id):
        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        return Response({
            "id": society.id,
            "name": society.name,
            "category": society.category,
            "description": society.description,
        })

    # PATCH update society description — admin only
    def patch(self, request, society_id):
        if request.user.role != "admin":
            return Response({"error": "Admin only"}, status=403)

        try:
            society = Society.objects.get(id=society_id, admin=request.user)
        except Society.DoesNotExist:
            return Response({"error": "Society not found or not your society"}, status=404)

        description = request.data.get("description")
        if description is not None:
            society.description = description
            society.save()

        return Response({
            "id": society.id,
            "name": society.name,
            "category": society.category,
            "description": society.description,
            "message": "Society updated successfully"
        })


class SocietyMembershipCheckView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, society_id):
        is_member = Membership.objects.filter(
            user=request.user,
            society_id=society_id,
            left_at__isnull=True
        ).exists()

        return Response({"is_member": is_member})
    
    