import 'shift.dart';

class Exam {

  Exam({
    required this.id,
    required this.clientCode,
    required this.code,
    required this.name,
    required this.projectCode,
    required this.fenceRadius,
    required this.shifts,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] ?? '',
      clientCode: json['clientCode'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      projectCode: json['projectCode'] ?? '',
      fenceRadius: json['fenceRadius'] ?? 0,
      shifts: (json['shifts'] as List<dynamic>?)
              ?.map((s) => Shift.fromJson(s))
              .toList() ??
          [],
    );
  }
  final String id;
  final String clientCode;
  final String code;
  final String name;
  final String projectCode;
  final int fenceRadius;
  final List<Shift> shifts;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientCode': clientCode,
      'code': code,
      'name': name,
      'projectCode': projectCode,
      'fenceRadius': fenceRadius,
      'shifts': shifts.map((s) => s.toJson()).toList(),
    };
  }
}
