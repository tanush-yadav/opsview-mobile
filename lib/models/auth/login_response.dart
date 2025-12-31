import 'user.dart';
import 'exam.dart';
import 'center.dart';

class LoginResponse {

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
    required this.exam,
    required this.center,
    required this.service,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      user: User.fromJson(json['user'] ?? {}),
      exam: Exam.fromJson(json['exam'] ?? {}),
      center: Center.fromJson(json['center'] ?? {}),
      service: json['service'] ?? '',
    );
  }
  final String accessToken;
  final String tokenType;
  final User user;
  final Exam exam;
  final Center center;
  final String service;

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'user': user.toJson(),
      'exam': exam.toJson(),
      'center': center.toJson(),
      'service': service,
    };
  }
}
