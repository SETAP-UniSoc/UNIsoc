
from rest_framework import serializers
from .models import Society, User
from .models import Event 

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

class SocietySerializer(serializers.ModelSerializer):
    member_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Society
        fields = '__all__'

    def get_member_count(self, obj):
        return obj.member_count

class EventSerializer(serializers.ModelSerializer):
    attendee_count = serializers.SerializerMethodField()
    class Meta:
        model = Event
        fields = "__all__"

    def get_attendee_count(self, obj):
        return obj.rsvps.count()


        