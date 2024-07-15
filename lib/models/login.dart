class LoginModel {
  String clientVersion;
  String deviceId;

  LoginModel({required this.clientVersion, required this.deviceId});

  Map<String, dynamic> toJson() {
    return {
      'clientVersion': clientVersion,
      'deviceId': deviceId,
    };
  }
}
