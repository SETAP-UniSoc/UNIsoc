from rest_framework import generics
from .models import User
from .models import Society
from .serializer import CustomerSerializer
from .serializer import SocietySerializer



class CustomerListView(generics.ListAPIView):
    serializer_class = CustomerSerializer

    def get_queryset(self):
        queryset = User.objects.all().order_by('name')

        search = self.request.query_params.get('search')
        letter = self.request.query_params.get('letter')

        if search:
            queryset = queryset.filter(name__icontains=search)

        if letter:
            queryset = queryset.filter(name__istartswith=letter)

        return queryset
    
class SocietyListView(generics.ListAPIView):
    queryset = Society.objects.all().order_by('name')
    serializer_class = SocietySerializer

    