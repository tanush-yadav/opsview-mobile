class ApiResponse {
  ApiResponse({
    required this.status,
    required this.code,
    this.data,
    this.message,
    this.notify,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] ?? '',
      code: json['code'] ?? '',
      data: json['data'],
      message: json['message'],
      notify: json['notify'] != null
          ? NotifyInfo.fromJson(json['notify'])
          : null,
    );
  }
  final String status;
  final String code;
  final dynamic data;
  final String? message;
  final NotifyInfo? notify;

  bool get isSuccess => status == 'SUCCESS';
}

class NotifyInfo {
  NotifyInfo({
    required this.message,
    required this.type,
    required this.timeout,
    required this.tag,
  });

  factory NotifyInfo.fromJson(Map<String, dynamic> json) {
    return NotifyInfo(
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      timeout: json['timeout'] ?? 2000,
      tag: json['tag'] ?? '',
    );
  }
  final String message;
  final String type;
  final int timeout;
  final String tag;
}
