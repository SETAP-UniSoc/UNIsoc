from django.urls import path
from .RegisterView import RegisterView
from .LoginView import LoginView
from .AnalyticsView import AnalyticsView
from .JoinSoc import JoinSocietyView
from .LeaveSoc import LeaveSocietyView
from .SocietyDetailView import SocietyDetailView
from .views import CustomerListView, SocietyListView

urlpatterns = [
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),
    path("society/<int:society_id>/join/", JoinSocietyView.as_view(), name="join-society"),
    path("society/<int:society_id>/leave/", LeaveSocietyView.as_view(), name="leave-society"),
    path('my-analytics/', AnalyticsView.as_view(), name="society-analytics"),
    path('societies/<int:society_id>/', SocietyDetailView.as_view(), name='society-detail'),
    path('customers/', CustomerListView.as_view(), name='customer-list-create'),
    path('societies/', SocietyListView.as_view(), name='society-list-create'),
]









