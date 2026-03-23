from rest_framework import generics
from .models import Customer
from .serializer import CustomerSerializer


class CustomerListView(generics.ListAPIView):
    serializer_class = CustomerSerializer

    def get_queryset(self):
        queryset = Customer.objects.all().order_by('name')

        search = self.request.query_params.get('search')
        letter = self.request.query_params.get('letter')

        if search:
            queryset = queryset.filter(name__icontains=search)

        if letter:
            queryset = queryset.filter(name__istartswith=letter)

        return queryset