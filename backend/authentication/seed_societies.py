from authentication.models import Society, User

def seed():
    admin = User.objects.filter(role='admin').first()
    societies = [
        {"name": "Football", "category": "Sports"},
        {"name": "Christianity", "category": "Religious"},
        {"name": "ACS", "category": "Cultural"},
        {"name": "Computer Science", "category": "Academic"},
        {"name": "Forex", "category": "Extra-curricular"},
        {"name": "South Asian", "category": "Cultural"},
        {"name": "Badminton", "category": "Sports"},
        {"name": "Debate", "category": "Academic"},
        {"name": "Photography", "category": "Extra-curricular"},
        {"name": "Arab", "category": "Cultural"},
    ]

    for soc in societies:
        defaults = {
            "category": soc["category"],
            "description": f"{soc['name']} Society",
        }
        if admin:
            defaults["admin"] = admin
        Society.objects.get_or_create(
            name=soc["name"],
            defaults=defaults
        )

    print("Societies seeded successfully.")