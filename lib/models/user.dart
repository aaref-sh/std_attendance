class User {
  int id;
  String fullName;
  String jobTitle;
  String college;
  String token;

  User({
    required this.id,
    required this.fullName,
    required this.jobTitle,
    required this.college,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['Id'] as int,
      fullName: json['FullName'] as String,
      jobTitle: json['JobTitle'] as String,
      college: json['College'] as String,
      token: json['Token'] as String,
    );
  }
}
