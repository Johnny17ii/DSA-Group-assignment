import ballerina/http;

service /lecturer/status on new http:Listener(9000) {

    resource function get lecturers() returns LecturerEntry[] {
        return lecturerTable.toArray();
    }

    resource function post lecturers(@http:Payload LecturerEntry[] lecturerEntries)
                                    returns LecturerEntry[]|ConflictingStaffNumberCodesError {

        string[] conflictingStaffNumbers = from LecturerEntry lecturerEntry in lecturerEntries
            where lecturerTable.hasKey(lecturerEntry.staffNumber)
            select lecturerEntry.staffNumber;

        if conflictingStaffNumbers.length() > 0 {
            return {
                body: {
                    errmsg: string:'join(" ", "Conflicting StaffNumber Id:", ...conflictingStaffNumbers)
                }
            };
        } else {
            lecturerEntries.forEach(letcurerEntry => lecturerTable.add(letcurerEntry));
            return lecturerEntries;
        }
    }

    resource function get lecturers/[string staffNumber]() returns LecturerEntry|InvalidStaffNumberCodeError {
        LecturerEntry? lecturerEntry = lecturerTable[staffNumber];
        if lecturerEntry is () {
            return {
                body: {
                    errmsg: string `Invalid StaffNumber Id: ${staffNumber}`
                }
            };
        }
        return lecturerEntry;
    }
}

public type LecturerEntry record {|
    readonly string staffNumber;
    string name;
|};

public final table<LecturerEntry> key(staffNumber) lecturerTable = table [
    {staffNumber: "001", name: "Angela"},
    {staffNumber: "002", name: "Sri Lanka"},
    {staffNumber: "003", name: "Makahala"}
];

public type ConflictingStaffNumberCodesError record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type InvalidStaffNumberCodeError record {|
    *http:NotFound;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};