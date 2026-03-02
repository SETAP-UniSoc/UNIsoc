from authentication.models import Society

def seed():
    societies = [
        {"name": "Football", "category": "Sports"},
        {"name": "Dance", "category": "Arts"},
        {"name": "Chess", "category": "Games"},
        {"name": "Computing", "category": "Academic"},
    ]

    for soc in societies:
        Society.objects.get_or_create(
            name=soc["name"],
            defaults={
                "category": soc["category"],
                "description": f"{soc['name']} Society"
            }
        )

    print("Societies seeded successfully.")