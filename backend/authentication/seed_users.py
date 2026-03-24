from authentication.models import User

def seed():
    users = [
        {
            "email": "admin1@test.com",
            "password": "password123",
            "role": "admin",
        },
        {
            "email": "admin2@test.com",
            "password": "password123",
            "role": "admin",
        },
        {
            "email": "user1@test.com",
            "password": "password123",
            "role": "user",
        },
        {
            "email": "user2@test.com",
            "password": "password123",
            "role": "user",
        },
    ]

    for u in users:
        if not User.objects.filter(email=u["email"]).exists():
            user = User.objects.create_user(
                email=u["email"],
                password=u["password"],
                role=u["role"],
            )
            print(f"Created user: {u['email']}")
        else:
            print(f"User already exists: {u['email']}")

    print("Users seeded successfully.")