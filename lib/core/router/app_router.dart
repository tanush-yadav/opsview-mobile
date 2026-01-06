import 'package:go_router/go_router.dart';

import '../../views/splash/splash_screen.dart';
import '../../views/login/login_screen.dart';
import '../../views/confirmation/confirmation_screen.dart';
import '../../views/profile/profile_flow_screen.dart';
import '../../views/shift_selection/shift_selection_screen.dart';
import '../../views/training/training_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/task_capture/task_capture_screen.dart';
import '../../views/settings/settings_screen.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const confirmation = '/confirmation';
  static const profile = '/profile';
  static const shiftSelection = '/shift-selection';
  static const training = '/training';
  static const home = '/home';
  static const taskCapture = '/task-capture';
  static const settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.confirmation,
      builder: (context, state) => const ConfirmationScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileFlowScreen(),
    ),
    GoRoute(
      path: AppRoutes.shiftSelection,
      builder: (context, state) => const ShiftSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.training,
      builder: (context, state) => const TrainingScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.taskCapture,
      builder: (context, state) {
        final taskId = state.uri.queryParameters['taskId'];
        return TaskCaptureScreen(taskId: taskId ?? '');
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
