import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'core/router/app_router.dart';
import 'services/sync/background_sync_service.dart';

class OpsViewApp extends ConsumerStatefulWidget {
  const OpsViewApp({super.key});

  @override
  ConsumerState<OpsViewApp> createState() => _OpsViewAppState();
}

class _OpsViewAppState extends ConsumerState<OpsViewApp> {
  @override
  void initState() {
    super.initState();
    // Start background sync service
    // We use addPostFrameCallback to ensure providers are ready, though not strictly necessary for simple providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backgroundSyncServiceProvider).start();
    });
  }

  @override
  void dispose() {
    // Optionally stop it when app is disposed (though app disposal usually means process death)
    ref.read(backgroundSyncServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadcnApp.router(
      title: 'Opsview',
      theme: ThemeData(
        colorScheme: LegacyColorSchemes.lightBlue(),
        radius: 0.5,
      ),
      routerConfig: appRouter,
    );
  }
}
