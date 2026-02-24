#from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.authtoken.models import Token
from .services import authenticate_user

class LoginView(APIView):

    def post(self, request):
        up_number = request.data.get("up_number")
        password = request.data.get("password")

        user = authenticate_user(up_number, password)

        if user is not None:
            token, created = Token.objects.get_or_create(user=user)

            return Response({
                "token": token.key,
                "role": user.role,
                "up_number": user.up_number
            })

        return Response(
            {"error": "Invalid credentials"},
            status=status.HTTP_401_UNAUTHORIZED
        )
    
