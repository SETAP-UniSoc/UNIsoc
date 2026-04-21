
from rest_framework import serializers
from .models import Society

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = '__all__'

class SocietySerializer(serializers.ModelSerializer):
    admin_email = serializers.EmailField(source='admin.email', read_only=True)
    member_count = serializers.IntegerField(source='members.count', read_only=True)
    
    class Meta:
        model = Society
        fields = ['id', 'name', 'category', 'description', 'admin_email', 'member_count']

