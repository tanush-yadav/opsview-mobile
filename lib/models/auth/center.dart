class Center {

  Center({
    required this.id,
    required this.examId,
    required this.clientCode,
    required this.code,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.zone,
    required this.description,
    required this.lat,
    required this.lng,
    required this.spoc1Name,
    required this.spoc1Contact,
    required this.spoc2Name,
    required this.spoc2Contact,
  });

  factory Center.fromJson(Map<String, dynamic> json) {
    return Center(
      id: json['id'] ?? '',
      examId: json['examId'] ?? '',
      clientCode: json['clientCode'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pinCode: json['pinCode'] ?? '',
      zone: json['zone'] ?? '',
      description: json['description'] ?? '',
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',
      spoc1Name: json['spoc1Name'] ?? '',
      spoc1Contact: json['spoc1Contact'] ?? '',
      spoc2Name: json['spoc2Name'] ?? '',
      spoc2Contact: json['spoc2Contact'] ?? '',
    );
  }
  final String id;
  final String examId;
  final String clientCode;
  final String code;
  final String name;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String zone;
  final String description;
  final String lat;
  final String lng;
  final String spoc1Name;
  final String spoc1Contact;
  final String spoc2Name;
  final String spoc2Contact;

  String get fullAddress => '$address, $city, $state - $pinCode';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examId': examId,
      'clientCode': clientCode,
      'code': code,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'zone': zone,
      'description': description,
      'lat': lat,
      'lng': lng,
      'spoc1Name': spoc1Name,
      'spoc1Contact': spoc1Contact,
      'spoc2Name': spoc2Name,
      'spoc2Contact': spoc2Contact,
    };
  }
}
