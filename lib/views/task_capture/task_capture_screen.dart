import 'package:shadcn_flutter/shadcn_flutter.dart';

class TaskCaptureScreen extends StatelessWidget {

  const TaskCaptureScreen({super.key, required this.taskId});
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Center(
        child: Text('Task Capture Screen - $taskId'),
      ),
    );
  }
}
