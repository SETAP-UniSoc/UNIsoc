--- users table to store user information
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    fname VARCHAR(50) NOT NULL,
    lname VARCHAR(50) NOT NULL,
    up_number VARCHAR(20) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user'
        CHECK (role IN ('user', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

--- socs table to store society information
CREATE TABLE societies (
    society_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- many-many society_admins table to link societies and their admins
--- multiple admins can manage a society, and an admin can manage multiple societies
CREATE TABLE society_admins (
    society_id INT REFERENCES societies(society_id) ON DELETE CASCADE,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL
        CHECK (role IN ('president','vice_president','treasurer','moderator')),
    PRIMARY KEY (society_id, user_id)
);

---membership requests to join --- approval 
CREATE TABLE membership_requests (
    request_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    society_id INT NOT NULL REFERENCES societies(society_id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'rejected')),
    request_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approval_timestamp TIMESTAMP,
    UNIQUE (user_id, society_id)
);


--- memberships approved members only 
CREATE TABLE memberships (
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    society_id INT NOT NULL REFERENCES societies(society_id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, society_id)
);

---events table to store event information for each society
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    society_id INT NOT NULL REFERENCES societies(society_id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    capacity_limit INT CHECK (capacity_limit IS NULL OR capacity_limit > 0),
    created_by INT REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'upcoming'
        CHECK (status IN ('upcoming','cancelled','completed')),
    CHECK (end_time > start_time)
);

--- events RSVPs and attendance tracking for users attending events
CREATE TABLE event_rsvps (
    event_id INT NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    rsvp_status VARCHAR(20) NOT NULL DEFAULT 'attending'
        CHECK (rsvp_status IN ('attending', 'not_attending')),
    rsvp_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, user_id)
);

--- Notification preferences for users to receive updates about their societies and events
CREATE TABLE notification_preferences (
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    society_id INT NOT NULL REFERENCES societies(society_id) ON DELETE CASCADE,
    notify BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (user_id, society_id)
);



-

