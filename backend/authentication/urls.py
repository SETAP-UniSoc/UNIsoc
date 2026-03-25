from django.urls import path
<<<<<<< HEAD

<<<<<<< HEAD
from UNIsoc.backend.authentication import CalanderView
=======
from UNIsoc.backend.authentication.views import CustomerListView
>>>>>>> c58e0ce2a04e1a656a1de5f17a638a5d99df0022
=======
>>>>>>> 2f9f065 (made chages)
from .RegisterView import RegisterView
from .LoginView import LoginView
from .AnalyticsView import AnalyticsView
from .JoinSoc import JoinSocietyView
from .LeaveSoc import LeaveSocietyView

urlpatterns = [
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),
    path("society/<int:society_id>/join/", JoinSocietyView.as_view(), name="join-society"),
    path("society/<int:society_id>/leave/", LeaveSocietyView.as_view(), name="leave-society"),
    path('my-analytics/', AnalyticsView.as_view(), name="society-analytics")

]






<<<<<<< HEAD
=======


<<<<<<< HEAD
>>>>>>> 2f9f065 (made chages)
=======

>>>>>>> 62d4619 (made chnages so url and added path to import socs)
