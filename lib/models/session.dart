class Session {
  late int id;
  late String branch;
  late String department;
  late String college;
  late String title;
  late String year;
  late String cycle;
  late String studentCount;

  Session.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    branch = json['Branch'];
    department = json['Department'];
    college = json['College'];
    title = json['Title'];
    year = json['Year'];
    cycle = json['Cycle'];
    studentCount = json['StudentCount'];
  }
}

class SessionStudents {
  final int sessionId;
  final List<String> studentIds;

  SessionStudents(this.sessionId, this.studentIds);
  // toJson method
  Map<String, dynamic> toJson() =>
      {'SessionId': sessionId, 'StudentIds': studentIds};
}
