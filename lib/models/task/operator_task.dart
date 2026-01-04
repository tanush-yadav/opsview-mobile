import 'dart:convert';

import '../auth/shift.dart';
import 'checklist_item.dart';
import 'task_meta_data.dart';

class OperatorTasksResponse {
  OperatorTasksResponse({required this.data});

  factory OperatorTasksResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return OperatorTasksResponse(
      data: dataList.map((e) => ShiftWithTasks.fromJson(e)).toList(),
    );
  }
  final List<ShiftWithTasks> data;
}

class ShiftWithTasks {
  ShiftWithTasks({required this.shift, required this.tasks});

  factory ShiftWithTasks.fromJson(Map<String, dynamic> json) {
    final tasksList = json['tasks'] as List<dynamic>? ?? [];
    return ShiftWithTasks(
      shift: Shift.fromJson(json['shift']),
      tasks: tasksList.map((e) => OperatorTask.fromJson(e)).toList(),
    );
  }
  final Shift shift;
  final List<OperatorTask> tasks;
}

class OperatorTask {
  OperatorTask({
    required this.id,
    required this.clientCode,
    required this.examId,
    required this.centerId,
    required this.shiftId,
    required this.service,
    required this.seqNumber,
    required this.required,
    required this.taskId,
    required this.taskLabel,
    required this.taskDesc,
    required this.taskType,
    required this.taskStatus,
    required this.centerCode,
    required this.centerName,
    this.metaData,
    this.checklist,
  });

  factory OperatorTask.fromJson(Map<String, dynamic> json) {
    // Parse metaData
    TaskMetaData? metaData;
    if (json['metaData'] != null) {
      metaData = TaskMetaData.fromJson(json['metaData']);
    }

    // Parse checklist
    List<ChecklistItem>? checklist;
    if (json['checklist'] != null) {
      final checklistList = json['checklist'] as List<dynamic>;
      checklist = checklistList.map((e) => ChecklistItem.fromJson(e)).toList();
    }

    return OperatorTask(
      id: json['id'] ?? '',
      clientCode: json['clientCode'] ?? '',
      examId: json['examId'] ?? '',
      centerId: json['centerId'] ?? '',
      shiftId: json['shiftId'] ?? '',
      service: json['service'] ?? '',
      seqNumber: json['seqNumber'] ?? 0,
      required: json['required'] ?? false,
      taskId: json['taskId'] ?? '',
      taskLabel: json['taskLabel'] ?? '',
      taskDesc: json['taskDesc'] ?? '',
      taskType: json['taskType'] ?? '',
      taskStatus: json['taskStatus'] ?? 'PENDING',
      centerCode: json['centerCode'] ?? '',
      centerName: json['centerName'] ?? '',
      metaData: metaData,
      checklist: checklist,
    );
  }

  final String id;
  final String clientCode;
  final String examId;
  final String centerId;
  final String shiftId;
  final String service;
  final int seqNumber;
  final bool required;
  final String taskId;
  final String taskLabel;
  final String taskDesc;
  final String taskType;
  final String taskStatus;
  final String centerCode;
  final String centerName;
  final TaskMetaData? metaData;
  final List<ChecklistItem>? checklist;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientCode': clientCode,
      'examId': examId,
      'centerId': centerId,
      'shiftId': shiftId,
      'service': service,
      'seqNumber': seqNumber,
      'required': required,
      'taskId': taskId,
      'taskLabel': taskLabel,
      'taskDesc': taskDesc,
      'taskType': taskType,
      'taskStatus': taskStatus,
      'centerCode': centerCode,
      'centerName': centerName,
      'metaData': metaData?.toJson(),
      'checklist': checklist?.map((e) => e.toJson()).toList(),
    };
  }

  /// Get metaDataJson string for database storage
  String? get metaDataJson =>
      metaData != null ? jsonEncode(metaData!.toJson()) : null;

  /// Get checklistJson string for database storage
  String? get checklistJson => checklist != null
      ? jsonEncode(checklist!.map((e) => e.toJson()).toList())
      : null;
}
