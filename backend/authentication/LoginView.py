from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from .models import Society  # ✅ IMPORT THIS

User = get_user_model()


class LoginView(APIView):
    def post(self, request):
        email = request.data.get("email")
        up_number = request.data.get("up_number")
        password = request.data.get("password")

        if not password:
            return Response({"error": "Password required"}, status=400)

        try:
            if email:
                user = User.objects.get(email__iexact=email)
            elif up_number:
                up_number = up_number.lower()
                if not up_number.startswith("up"):
                    up_number = f"up{up_number}"
                user = User.objects.get(up_number__iexact=up_number)
            else:
                return Response({"error": "Email or UP number required"}, status=400)

            if user.check_password(password):
                token, _ = Token.objects.get_or_create(user=user)

                # ✅ GET SOCIETY FOR ADMIN
                society_id = None
                society_name = None

                if user.role == "admin":
                    try:
                        society = Society.objects.get(admin=user)
                        society_id = society.id
                        society_name = society.name
                    except Society.DoesNotExist:
                        pass

                return Response({
                    "token": token.key,
                    "role": user.role,
                    "email": user.email,
                    "up_number": user.up_number,
                    "society_id": society_id,      # ✅ ADD THIS
                    "society_name": society_name   # ✅ ADD THIS
                })

        except User.DoesNotExist:
            pass

        return Response({"error": "Invalid credentials"}, status=401)