import ballerina/io;
import ballerina/sql;
import ballerina/uuid;
import ballerinax/kafka;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

// Trip record type
public type Trips record {|
    string tripId;
    string trip_name;
    string departure_time; // e.g., "2025-09-28 07:00:00"
    string arrival_time; // e.g., "2025-09-28 07:45:00"
    string vehicleId?;
    decimal price;
    string status = "SCHEDULED"; // SCHEDULED, ONGOING, COMPLETED, CANCELLED
|};

type TripSummary record {|
    string trip_id;
    string trip_name;
    string departure_time;
|};

public type Disruption record {|
    string disruptionId;
    string title;
    string description?;
    string createdAt?;
|};

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final mysql:Client dbClient = check new (
    host = HOST,
    user = USER,
    password = PASSWORD,
    port = PORT,
    database = DATABASE
);

configurable string KAFKA_BROKE = "localhost:9092";

// Producer configuration
kafka:ProducerConfiguration producerConfig = {
    clientId: "scheduleUpdates",
    acks: "all"
};

kafka:Producer producer = check new (KAFKA_BROKE, producerConfig);

function manageTrips() returns error? {
    io:println("\n--- Manage Trips ---");
    io:println("1. Update Trip");
    io:println("2. Delete Trip");
    io:println("3. back to Admin Menu");

    io:print("Enter your choice: ");
    int choice = check int:fromString(io:readln());

    match choice {
        1 => {
            check updateTrip();
        }

        2 => {
            check deleteTrip();
        }

        3 => {
            io:println("Returning to Admin Menu...");
            adminMenu();
        }
        _ => {
            io:println("Invalid choice, try again.");
        }
    }
}
