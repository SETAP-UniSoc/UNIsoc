"""
Serializers for converting UNIsoc models to JSON.
"""

from rest_framework import serializers
from .models import NotificationPreference, Society, User
from .models import Event, NotificationPreference

class UserSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id",
            "email",
            "up_number",
            "role",
            "first_name",
            "last_name",
            "full_name",
            "created_at"
        ]
        read_only_fields = ["id", "role", "created_at"]

    def get_full_name(self, obj):
        return f"{obj.first_name} {obj.last_name}".strip()

class SocietySerializer(serializers.ModelSerializer):
    member_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Society
        fields = '__all__'

    def get_member_count(self, obj):
        return obj.membership.filter(left_at__isnull=True).count()



from rest_framework import serializers
from .models import Event

class EventSerializer(serializers.ModelSerializer):
    attendee_count = serializers.SerializerMethodField(read_only=True)
    society_name = serializers.CharField(source="society.name", read_only=True)
    society_id = serializers.IntegerField(source="society.id", read_only=True)

    class Meta:
        model = Event
        fields = [
            'id',
            'title',
            'description',
            'location',
            'start_time',
            'end_time',
            'capacity_limit',
            'status',
            'attendee_count',
            'society_name',
            'society_id'
        ]
        read_only_fields = ['id', 'attendee_count', 'society_name', 'society_id']

    def get_attendee_count(self, obj):
        return obj.eventattendance_set.filter(left_at__isnull=True).count()

class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = "__all__"
    read_only_fields = ['user', 'id']


        
