from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.authtoken.models import Token

class LoginView(APIView):

    def post(self, request):
        up_number = request.data.get("up_number")
        password = request.data.get("password")

        user = authenticate(
            request,
            username=up_number,
            password=password
        )

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
    
    