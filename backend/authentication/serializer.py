
from rest_framework import serializers
from .models import Society, User

class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Society
        fields = '__all__'