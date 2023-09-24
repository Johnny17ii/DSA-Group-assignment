import ballerina/http;


service /lecturer on new http:Listener(9090){
    //
    private table<Lecturer> key(staffNumber) lecturers;
    private table<Office> key(officeId) offices;

    function init() {
        self.lecturers = table [];
        self.offices = table [];
    }

    isolated resource function get all() returns Lecturer[] {
        return self.lecturers.toArray();
    }

    resource function get lecturers/[string staffNumber]() returns Lecturer|InvalidLecturer{
        Lecturer? course = self.lecturers[staffNumber];

        if course == () {
            return <InvalidLecturer>{
                body: {ErrorMsg: string `Error: lecturer doesnt exist`}
            };
        } else {
            return course;
        }
    }

    resource function post lecturers(@http:Payload Lecturer newLecturer) returns ExistingLecturer|ConflictingStaffNumber {
        string[] existingCourses = from var {staffNumber} in self.lecturers
            where staffNumber == newLecturer.staffNumber select staffNumber;
            
        if existingCourses.length() > 0 {
            return <ConflictingStaffNumber> {
                body: {
                    ErrorMsg: string `Error: Conflicting staff number!`
                }
            };
        } else {
            self.lecturers.add(newLecturer);

            return <ExistingLecturer>{body: newLecturer};
        }
    }
}

// Adding the definition of the record
public type Lecturer record {|
    readonly string staffNumber;
    string name;
    string officeId;
    string[] courseId;
|};

public type Office record {|
    readonly string officeId;
    string name;
|};

public type ConflictingStaffNumber record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string ErrorMsg;
|};

public type ExistingLecturer record {|
    *http:Created;
    Lecturer body;
|};

public type InvalidLecturer record{|
    *http:NotFound;
    ErrorMsg body;
|};