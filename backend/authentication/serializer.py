
from rest_framework import serializers
from .models import NotificationPreference, Society, User
from .models import Event, NotificationPreference

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
        return obj.membership.filter(left_at__isnull=True).count()

class EventSerializer(serializers.ModelSerializer):
    attendee_count = serializers.SerializerMethodField()
    class Meta:
        model = Event
        fields = "__all__"

    def get_attendee_count(self, obj):
        return obj.rsvps.count()

class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = "__all__"
    read_only_fields = ['user', 'id']


        