import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerina/uuid;
import ballerinax/kafka;
import ballerinax/mysql;

// db configaration
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

// kafka config
configurable string KAFKA_BROKER = "localhost:9092";

kafka:ConsumerConfiguration consumerConfig = {
    groupId: "passengerService",
    topics: ["trips", "notifications"],
    pollingInterval: 1,
    offsetReset: "earliest"
};

listener kafka:Listener consumerListener = new (KAFKA_BROKER, consumerConfig);

public type Passenger record {|
    string passenger_id;
    string first_name;
    string last_name;
    string email;
    string password;
    string phone;
|};

public type Ticket record {|
    string ticket_id;
    string passenger_id?;
    string trip_id;
    string ticket_type;
    string status = "CREATED";
|};

string? currentPassengerId = ();

public function main() returns error? {
    io:println("PASSAGER SERVIVICE STARTED");
    check authMenu();
}

function authMenu() returns error? {
    while true {
        io:println("\n--- Welcome Passenger ---");
        io:println("1. Create Account");
        io:println("2. Login");
        io:println("3. Exit");
        io:print("Enter choice: ");
        int choice = check int:fromString(io:readln());

        match choice {
            1 => {
                check createAccount();
            }
            2 => {
                string? loggedInId = check login();

                if loggedInId is string {
                    currentPassengerId = loggedInId;
                    io:println("Login successful! Opening Passenger Menu...");
                    check passengerSelection();
                }
            }

            3 => {
                io:print("Goodbye!");
                break;
            }
            _ => {
                io:println("Invalid choice.");
            }
        }
    }
}
function passengerMenu() {
    io:println("\nPassenger Menu");
    io:println("1. Browse Trips");
    io:println("2. Purchase Ticket");
    io:println("3. Validate Ticket");
    io:println("4. Logout");
}

function passengerSelection() returns error? {
    while true {
        passengerMenu();
        io:print("Enter choice: ");
        int choice = check int:fromString(io:readln());

        match choice {
            1 => {
                check browseTrips();
            }
            2 => {
                check purchaseTicket();
            }

            3 => {
                check validateTicket();
            }

            4 => {
                io:println("Logging out...");
                currentPassengerId = ();
                break; // return to auth menu
            }
            _ => {
                io:println("Invalid choice, try again.");
            }
        }
    }
}
