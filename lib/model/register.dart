class Register {
  int sno;
  String name;
  String email;
  String mobileno;
  String courseId;
  String firstMonday;
  String joiningDate;
  String enteredDate;
  String dob;
  String fatherName;
  String currentClass;
  String target;
  String schoolName;
  String marks10;
  String marks12;
  String address;
  String accountType;

  Register();

  Register.fromJson(Map<String, dynamic> json) {
    sno = json['sno'];
    name = json['name'];
    email = json['email'];
    mobileno = json['mobileno'];
    courseId = json['courseId'];
    firstMonday = json['firstMonday'];
    joiningDate = json['joiningDate'];
    enteredDate = json['enteredDate'];
    accountType=json['accountType'];
    dob = json['dob'];
    fatherName = json['fatherName'];
    currentClass = json['currentClass'];
    target = json['target'];
    schoolName = json['schoolName'];
    marks10 = json['marks10'];
    marks12 = json['marks12'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sno'] = sno;
    data['name'] = name;
    data['email'] = email;
    data['mobileno'] = mobileno;
    data['courseId'] = courseId;
    data['firstMonday'] = firstMonday;
    data['joiningDate'] = joiningDate;
    data['enteredDate'] = enteredDate;
    data['accountType'] = accountType;
    data['dob'] = dob;
    data['fatherName'] = fatherName;
    data['currentClass'] = currentClass;
    data['target'] = target;
    data['schoolName'] = schoolName;
    data['marks10'] = marks10;
    data['marks12'] = marks12;
    data['address'] = address;
    return data;
  }
}
