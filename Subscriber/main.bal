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
