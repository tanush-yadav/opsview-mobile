import 'package:shadcn_flutter/shadcn_flutter.dart';

class TaskCaptureScreen extends StatelessWidget {
  final String taskId;

  const TaskCaptureScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Center(
        child: Text('Task Capture Screen - $taskId'),
      ),
    );
  }
}
