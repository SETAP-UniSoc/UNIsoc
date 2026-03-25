from rest_framework import serializers
from .models import Society
from .models import Event 

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
<<<<<<< HEAD
    
=======

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = "__all__"

        

        
>>>>>>> stuti-up2199677
