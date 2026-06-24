import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_placeholder_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardPlaceholderScreen(),
    ),
  ],
);
