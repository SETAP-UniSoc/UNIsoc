from rest_framework import serializers
from .models import Society

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = Society
        fields = '__all__'

class SocietySerializer(serializers.ModelSerializer):
    member_count = serializers.SerializerMethodField()

    class Meta:
        model = Society
        fields = '__all__'

    def get_member_count(self, obj):
        return obj.member_count
    