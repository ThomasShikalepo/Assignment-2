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

function createTrip() returns error? {
    io:println("\n--- Admin: Add a Trip ---");
    io:print("Trip Name: ");
    string tripName = io:readln();

    if tripName == "exit" {
        io:println("Cancelled trip creation.");
        return;
    }

    io:print("Departure Time (yyyy-mm-dd hh:mm:ss): ");
    string departureTime = io:readln();

    io:print("Arrival Time (yyyy-mm-dd hh:mm:ss): ");
    string arrivalTime = io:readln();

    io:print("Ticket Price: ");
    decimal price = check decimal:fromString(io:readln());

    io:print("Vehicle ID: ");
    string vehicleId = io:readln();

    // Create Trip record
    Trips trip = {
        tripId: uuid:createType1AsString(),
        trip_name: tripName,
        departure_time: departureTime,
        arrival_time: arrivalTime,
        vehicleId: vehicleId,
        price: price,
        status: "SCHEDULED"
    };

    // Insert into database
    sql:ExecutionResult _ = check dbClient->execute(
    `INSERT INTO trips (trip_id, trip_name, departure_time, arrival_time, vehicle_Id,status, price)
     VALUES (${trip.tripId}, 
     ${trip.trip_name}, 
     ${trip.departure_time}, 
     ${trip.arrival_time}, 
     ${trip.vehicleId}, 
     ${trip.status}, 
     ${trip.price})`
    );

    // Convert Trip to JSON
    json tripJson = <json>trip;

    check publishTripEvent("CREATE", trip);
    io:println("Trip Created: " + tripJson.toJsonString());
}
