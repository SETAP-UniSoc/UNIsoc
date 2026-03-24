from authentication.models import Society, Event, User
from django.utils import timezone
from datetime import timedelta

def seed():
    societies = Society.objects.all()
    admin_user = User.objects.filter(role='admin').first()

    if not societies.exists():
        print("No societies found. Seed societies first.")
        return

    if not admin_user:
        print("No admin user found. Create one first.")
        return

    for soc in societies:
        for i in range(2):  # 2 events per society
            Event.objects.get_or_create(
                title=f"{soc.name} Event {i+1}",
                society=soc,
                defaults={
                    "description": f"Event for {soc.name}",
                    "location": "Campus Hall",
                    "start_time": timezone.now() + timedelta(days=i+1),
                    "end_time": timezone.now() + timedelta(days=i+1, hours=2),
                    "created_by": admin_user,
                    "status": "upcoming",
                }
            )

    print("Events seeded successfully.")

    