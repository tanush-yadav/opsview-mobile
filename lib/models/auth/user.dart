class User {

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.active,
    required this.roles,
    this.userType,
    this.centerCode,
    this.clientCode,
    this.photoUrl,
    this.examId,
    this.examCode,
    this.centerId,
    this.service,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      active: json['active'] ?? false,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((r) => Role.fromJson(r))
              .toList() ??
          [],
      userType: json['userType'],
      centerCode: json['centerCode'],
      clientCode: json['clientCode'],
      photoUrl: json['photoUrl'],
      examId: json['examId'],
      examCode: json['examCode'],
      centerId: json['centerId'],
      service: json['service'],
    );
  }
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final bool active;
  final List<Role> roles;
  final String? userType;
  final String? centerCode;
  final String? clientCode;
  final String? photoUrl;
  final String? examId;
  final String? examCode;
  final String? centerId;
  final String? service;

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'active': active,
      'roles': roles.map((r) => r.toJson()).toList(),
      'userType': userType,
      'centerCode': centerCode,
      'clientCode': clientCode,
      'photoUrl': photoUrl,
      'examId': examId,
      'examCode': examCode,
      'centerId': centerId,
      'service': service,
    };
  }
}

class Role {

  Role({
    required this.id,
    required this.name,
    required this.description,
    required this.shortName,
    required this.deleted,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      shortName: json['shortName'] ?? '',
      deleted: json['deleted'] ?? 0,
    );
  }
  final int id;
  final String name;
  final String description;
  final String shortName;
  final int deleted;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shortName': shortName,
      'deleted': deleted,
    };
  }
}
