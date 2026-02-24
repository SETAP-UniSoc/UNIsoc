from django.urls import path
from loginAPIview import LoginView

urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
]

