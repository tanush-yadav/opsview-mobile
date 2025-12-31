import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../viewmodels/splash_viewmodel.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final route =
        await ref.read(splashViewModelProvider.notifier).getInitialRoute();

    if (!mounted) return;

    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: SafeArea(
        child: Column(
          children: [
            Spacer(flex: 2),
            // Shield Icon
            Icon(
              Icons.shield_outlined,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            // App Name
            Text('OpsView', style: AppTextStyles.h1),
            Spacer(flex: 3),
            // Loading Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    'Verifying Session...',
                    style: AppTextStyles.muted,
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
