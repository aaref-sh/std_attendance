class UploadedExam {
  final String examId;
  final List<Student> students;

  UploadedExam(this.examId, this.students);

  factory UploadedExam.fromJson(Map<String, dynamic> json) {
    return UploadedExam(
      json['ExamId'] as String,
      (json['Students'] as List<dynamic>)
          .map((studentJson) => Student.fromJson(studentJson))
          .toList(),
    );
  }
}

class Student {
  final String studentId;
  final String fullName;
  final String father;
  final String status;

  Student(this.studentId, this.fullName, this.father, this.status);

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      json['StudentId'] as String,
      json['FullName'] as String,
      json['Father'] as String,
      json['Status'] as String,
    );
  }
}

class ApiCheckInModel {
  String? studentId;
  int? sessionId;

  ApiCheckInModel({this.studentId, this.sessionId});

  Map<String, dynamic> toJson() {
    return {
      'StudentId': studentId,
      'SessionId': sessionId,
    };
  }
}
