import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'core/router/app_router.dart';

class OpsViewApp extends StatelessWidget {
  const OpsViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp.router(
      title: 'OpsView',
      theme: ThemeData(
        colorScheme: LegacyColorSchemes.lightBlue(),
        radius: 0.5,
      ),
      routerConfig: appRouter,
    );
  }
}
