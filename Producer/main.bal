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