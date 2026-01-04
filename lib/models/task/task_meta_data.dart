/// Metadata for task instructions display
class TaskMetaData {
  TaskMetaData({
    required this.taskInstructionHeader,
    required this.taskInstructionSubHeader,
    required this.taskInstructionIcon,
    required this.taskInstructionSet,
  });

  factory TaskMetaData.fromJson(Map<String, dynamic> json) {
    final instructionSet = json['task_instructionSet'] as List<dynamic>? ?? [];
    return TaskMetaData(
      taskInstructionHeader: json['taskInstructionHeader'] ?? '',
      taskInstructionSubHeader: json['taskInstructionSubHeader'] ?? '',
      taskInstructionIcon: json['taskInstructionIcon'] ?? '',
      taskInstructionSet: instructionSet.map((e) => e.toString()).toList(),
    );
  }

  final String taskInstructionHeader;
  final String taskInstructionSubHeader;
  final String taskInstructionIcon;
  final List<String> taskInstructionSet;

  Map<String, dynamic> toJson() {
    return {
      'taskInstructionHeader': taskInstructionHeader,
      'taskInstructionSubHeader': taskInstructionSubHeader,
      'taskInstructionIcon': taskInstructionIcon,
      'task_instructionSet': taskInstructionSet,
    };
  }
}
