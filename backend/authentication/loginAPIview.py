from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.authtoken.models import Token
from django.contrib.auth import get_user_model

User = get_user_model()

class LoginView(APIView):

    def post(self, request):
        up_number = request.data.get("up_number")
        email = request.data.get("email")
        password = request.data.get("password")

        user = None

        # Student login
        if up_number:
            try:
                user = User.objects.get(up_number=up_number)
                if not user.check_password(password):
                    user = None
            except User.DoesNotExist:
                user = None

        # Admin login
        elif email:
            try:
                user = User.objects.get(email=email)
                if not user.check_password(password):
                    user = None
            except User.DoesNotExist:
                user = None

        if user:
            token, created = Token.objects.get_or_create(user=user)

            return Response({
                "token": token.key,
                "role": getattr(user, "role", "admin"),
                "email": user.email,
            })

        return Response(
            {"error": "Invalid credentials"},
            status=status.HTTP_401_UNAUTHORIZED
        )