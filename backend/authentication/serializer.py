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
        from rest_framework import serializers
from .models import Event

class EventSerializer(serializers.ModelSerializer):
    attendee_count = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Event
        # Only include fields that can be set via POST
        fields = [
            'id',
            'title',
            'description',
            'start_time',
            'end_time',
            'location',  # if you have this
            'society',
            'attendee_count',
        ]
        read_only_fields = ['id', 'attendee_count', 'society']  # society can be set from URL in the view

    def get_attendee_count(self, obj):
        return obj.rsvps.count()

class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = "__all__"
    read_only_fields = ['user', 'id']


        
