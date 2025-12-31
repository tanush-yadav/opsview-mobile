class Shift {

  Shift({
    required this.id,
    required this.clientCode,
    required this.examCode,
    required this.name,
    required this.type,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.services,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] ?? '',
      clientCode: json['clientCode'] ?? '',
      examCode: json['examCode'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      startDate: json['startDate'] ?? '',
      startTime: json['startTime'] ?? '',
      endDate: json['endDate'] ?? '',
      endTime: json['endTime'] ?? '',
      services: (json['services'] as List<dynamic>?)
              ?.map((s) => ShiftService.fromJson(s))
              .toList() ??
          [],
    );
  }
  final String id;
  final String clientCode;
  final String examCode;
  final String name;
  final String type;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final List<ShiftService> services;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientCode': clientCode,
      'examCode': examCode,
      'name': name,
      'type': type,
      'startDate': startDate,
      'startTime': startTime,
      'endDate': endDate,
      'endTime': endTime,
      'services': services.map((s) => s.toJson()).toList(),
    };
  }
}

class ShiftService {

  ShiftService({
    required this.name,
    required this.templateName,
    required this.trainingLink,
  });

  factory ShiftService.fromJson(Map<String, dynamic> json) {
    return ShiftService(
      name: json['name'] ?? '',
      templateName: json['templateName'] ?? '',
      trainingLink: json['trainingLink'] ?? '',
    );
  }
  final String name;
  final String templateName;
  final String trainingLink;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'templateName': templateName,
      'trainingLink': trainingLink,
    };
  }
}
