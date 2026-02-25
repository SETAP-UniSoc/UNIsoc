from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.authtoken.models import Token
from django.contrib.auth import get_user_model

User = get_user_model()

class LoginView(APIView):
    def post(self, request):
        email = request.data.get("email")
        password = request.data.get("password")
        
        print(f"DEBUG: Email='{email}', Password='{password}'")  
        
        if not email or not password:
            return Response({"error": "Email and password required"}, 
                          status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(email=email)
            print(f"DEBUG: Found user: {user.email}")
            
            if user.check_password(password):
                print("DEBUG: Password correct!")
                token, _ = Token.objects.get_or_create(user=user)
                return Response({
                    "token": token.key,
                    "role": getattr(user, "role", "user"),  
                    "email": user.email,
                })
            else:
                print("DEBUG: Password WRONG")
                
        except User.DoesNotExist:
            print("DEBUG: User not found")

        return Response({"error": "Invalid credentials"}, 
                       status=status.HTTP_401_UNAUTHORIZED)
