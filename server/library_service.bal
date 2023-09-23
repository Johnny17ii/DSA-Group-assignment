import ballerina/grpc;
import ballerina/io;

listener grpc:Listener ep = new (9090);

type BookRecord record {
    Book book;
    int quantity;
};

// Maintain a collection of library books.
map<string> libraryBooksMap = {};

// Implement a data structure to hold book records.
map<string> bookRecordsMap = {};

@grpc:Descriptor { value: LIBRARY_DESC }
service "Library" on ep {

    // Function to add a book to the library.
    remote function addBook(Book value) returns string|error {
        // Generate a unique ISBN for the book (you can implement your logic here).
        string isbn = generateUniqueISBN();
        value.isbn = isbn;

        // Add the book to the library.
        libraryBooksMap[isbn] = value;

        // Create a book record with an initial quantity of 1.
        bookRecordsMap[isbn] = {book: value, quantity: 1};

        // Return the ISBN of the added book.
        return isbn;
    }

    // Function to create users.
    remote function createUsers(stream<User, grpc:Error?> clientStream) returns string|error {
        // Initialize a string to collect user IDs.
        string userIDs = "";

        // Iterate through the stream of users and process each one.
        while (true) {
            var userResult = clientStream->receive();
            if (userResult is User) {
                // Process the user (you can implement your logic here).
                userIDs += userResult.id + ", ";
            } else if (userResult is grpc:Error) {
                // Handle errors if needed.
                io:println("Error received from client stream: " + userResult);
                break;
            } else {
                // End of stream.
                break;
            }
        }

        // Return the list of created user IDs.
        return "Created users with IDs: " + userIDs;
    }

    // Function to update a book.
    remote function updateBook(Book value) returns string|error {
        // Check if the book exists in the library.
        if (libraryBooksMap.exists(value.isbn)) {
            // Update the book in the library.
            libraryBooksMap[value.isbn] = value;
            return "Book updated successfully.";
        } else {
            return "Book with ISBN " + value.isbn + " not found.";
        }
    }

    // Function to remove a book from the library.
    remote function removeBook(string value) returns Book|error {
        // Check if the book exists in the library.
        if (libraryBooksMap.exists(value)) {
            // Remove the book from the library.
            var removedBook = libraryBooksMap[value];
            libraryBooksMap.delete(value);
            bookRecordsMap.delete(value);
            return removedBook;
        } else {
            return error("Book with ISBN " + value + " not found.");
        }
    }

    // Function to list available books.
    remote function listAvailableBooks() returns stream<Book, error?>|error {
        // Create a stream of available books.
        var availableBooks = new grpc:InMemoryRecordIterator();

        foreach var record in bookRecordsMap {
            var book = record.book;
            if (book.status) {
                availableBooks->push(book);
            }
        }

        return availableBooks;
    }

    // Function to locate a book by ISBN.
    remote function locateBook(locBook value) returns Book|error {
        // Check if the book exists in the library.
        if (libraryBooksMap.exists(value.book_isbn)) {
            // Get the book from the library.
            return libraryBooksMap[value.book_isbn];
        } else {
            return error("Book with ISBN " + value.book_isbn + " not found.");
        }
    }

    // Function to allow a student to borrow a book.
    remote function borrowBook(Request value) returns string|error {
        // Check if the book exists in the library.
        if (libraryBooksMap.exists(value.book_isbn)) {
            var bookRecord = bookRecordsMap[value.book_isbn];
            var book = bookRecord.book;
            
            // Check if the book is available.
            if (book.status && bookRecord.quantity > 0) {
                // Decrease the quantity of the book.
                bookRecord.quantity = bookRecord.quantity - 1;
                
                // Update the book record.
                bookRecordsMap[value.book_isbn] = bookRecord;
                
                // Return a success message.
                return "Book with ISBN " + value.book_isbn + " borrowed by user " + value.user_id;
            } else {
                return "Book with ISBN " + value.book_isbn + " is not available for borrowing.";
            }
        } else {
            return error("Book with ISBN " + value.book_isbn + " not found.");
        }
    }
}
