import re
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model
from django.urls import path

User = get_user_model()

class RegisterView(APIView):
    def post(self, request):
        first_name = request.data.get("first_name")
        last_name = request.data.get("last_name")
        email = request.data.get("email")
        up_number = request.data.get("up_number")
        password = request.data.get("password")
        confirm_password = request.data.get("confirm_password")

        if not all([first_name, last_name, email, up_number, password, confirm_password]):
            return Response(
                {"error": "All fields are required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        if password != confirm_password:
            return Response(
                {"error": "Passwords do not match"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Password strength validation
        if len(password) < 8:
            return Response(
                {"error": "Password must be at least 8 characters long"},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not re.search(r"[A-Z]", password):
            return Response(
                {"error": "Password must contain at least one uppercase letter"},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not re.search(r"[0-9]", password):
            return Response(
                {"error": "Password must contain at least one number"},
                status=status.HTTP_400_BAD_REQUEST
            )   

        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
            return Response(
                {"error": "Password must contain at least one special character"},
                status=status.HTTP_400_BAD_REQUEST
         )

        if User.objects.filter(email=email).exists():
            return Response(
                {"error": "Email already exists"},
                status=status.HTTP_400_BAD_REQUEST
            )

        if User.objects.filter(up_number=up_number).exists():
            return Response(
                {"error": "UP number already exists"},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = User.objects.create_user(
            email=email,
            password=password,
            up_number=up_number,
            first_name=first_name,
            last_name=last_name,
            role="user"
        )

        return Response(
            {"message": "User registered successfully", "user": {
                "email": user.email,
                "up_number": user.up_number,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "role": user.role
            }},
            status=status.HTTP_201_CREATED
        )

