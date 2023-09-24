import ballerina/io;

LibraryClient ep = check new ("http://localhost:9090");

public function main() returns error? {
   
     // Add Book request 
    Book addBookRequest = {isbn: "ballerina", title: "ballerina", author_1: "ballerina", author_2: "ballerina", location: "ballerina", status: true};
    string addBookResponse = check ep->addBook(addBookRequest);
    io:println(addBookResponse);

     // Update a Book request
    Book updateBookRequest = {isbn: "ballerina", title: "ballerina", author_1: "ballerina", author_2: "ballerina", location: "ballerina", status: true};
    string updateBookResponse = check ep->updateBook(updateBookRequest);
    io:println(updateBookResponse);

     //  Remmove a Book request
    string removeBookRequest = "ballerina";
    Book removeBookResponse = check ep->removeBook(removeBookRequest);
    io:println(removeBookResponse);

     // Locate a Book request
    locBook locateBookRequest = {book_isbn: "ballerina"};
    Book locateBookResponse = check ep->locateBook(locateBookRequest);
    io:println(locateBookResponse);

     // Borrow a Book request
    Request borrowBookRequest = {user_id: "ballerina", book_isbn: "ballerina"};
    string borrowBookResponse = check ep->borrowBook(borrowBookRequest);
    io:println(borrowBookResponse);
    stream<

     // List Available Books request
Book, error?> listAvailableBooksResponse = check ep->listAvailableBooks();
    check listAvailableBooksResponse.forEach(function(Book value) {
        io:println(value);
    });

     // Create User request
    User createUsersRequest = {id: "ballerina", name: "ballerina"};
    CreateUsersStreamingClient createUsersStreamingClient = check ep->createUsers();
    check createUsersStreamingClient->sendUser(createUsersRequest);
    check createUsersStreamingClient->complete();
    string? createUsersResponse = check createUsersStreamingClient->receiveString();
    io:println(createUsersResponse);
}

