CREATE DATABASE IF NOT EXISTS smart_transport;
USE smart_transport;

CREATE TABLE passengers (
    passenger_id CHAR(36) PRIMARY KEY,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(150) UNIQUE NOT NULL,
    password     VARCHAR(255) NOT NULL,
    phone        VARCHAR(50),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE routes (
    route_id CHAR(36) PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL,
    start_point VARCHAR(100) NOT NULL,
    end_point   VARCHAR(100) NOT NULL
);

CREATE TABLE trips (
    trip_id CHAR(36) PRIMARY KEY,
    departure_time DATETIME NOT NULL,
    arrival_time   DATETIME NOT NULL,
    capacity INT DEFAULT 50,
    status ENUM('SCHEDULED','DELAYED','CANCELLED','COMPLETED') DEFAULT 'SCHEDULED'
);

CREATE TABLE tickets (
    ticket_id CHAR(36) PRIMARY KEY,
    ticket_type ENUM('SINGLE','MULTI','PASS') DEFAULT 'SINGLE',
    status ENUM('CREATED','PAID','VALIDATED','EXPIRED') DEFAULT 'CREATED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payments (
    payment_id CHAR(36) PRIMARY KEY,
    amount DECIMAL(10,2) NOT NULL,
    method ENUM('CASH','CARD','MOBILE') DEFAULT 'CARD',
    status ENUM('PENDING','SUCCESS','FAILED') DEFAULT 'PENDING'
);

CREATE TABLE disruptions (
    disruption_id CHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE trips 
MODIFY COLUMN status ENUM('SCHEDULED','ONGOING','DELAYED','CANCELLED','COMPLETED') DEFAULT 'SCHEDULED';
