from django.urls import path
from .RegisterView import RegisterView
from .LoginView import LoginView

urlpatterns = [
    path("api/admin/login/", LoginView.as_view(), name="admin-login"),
    path("api/user/login/", LoginView.as_view(), name="user-login"),
    path("api/user/register/", RegisterView.as_view(), name="user-register"),
]

