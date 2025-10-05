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

function adminMenu() {
    io:println("\nAdmin Menu");
    io:println("1. create Trip");
    io:println("2. Manage Trips(update/cancel)");
    io:println("3. Publish Service Disruptions or Schedule Updates");
    io:println("4. View Ticket Sales Reports");
    io:println("5. Exit");
}

function adminSelection() returns error? {
    while true {
        adminMenu();
        io:println("Enter your Choice: ");
        int choice = check int:fromString(io:readln());

        match choice {
            1 => {
                check createTrip();
            }
            2 => {
                check manageTrips();
            }
            3 => {
                check publishDisruption();
            }
            4 => {
                check viewReports();
            }
            5 => {
                io:println("Exiting Admin menu...");
                break;
            }
            _ => {
                io:println("Invalid choice, try again.");
            }
        }
    }
}


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
function deleteTrip() returns error? {
    io:println("\n--- Delete Trip ---");
    io:print("Enter Trip ID to delete: ");
    string tripId = io:readln();

    // Fetch trip before deleting
    stream<record {|anydata...;|}, sql:Error?> queryResult = dbClient->query(
        `SELECT * FROM trips WHERE trip_id = ${tripId}`
    );
    record {}? fetchedTrip = check queryResult.next();

    // Delete the trip
    sql:ExecutionResult _ = check dbClient->execute(
        `DELETE FROM trips WHERE trip_id = ${tripId}`
    );

    // Publish Kafka event
    if fetchedTrip is record {} {
        // Convert record to JSON safely
        json tripJson = check <json>fetchedTrip;
        check publishTripEvent("DELETE", tripJson);
    }

    io:println("Trip deleted successfully!");
