import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_placeholder_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/profile/presentation/profile_settings_screen.dart';
import '../../features/wallets/presentation/add_wallet_screen.dart';
import '../../features/wallets/presentation/edit_wallet_screen.dart';
import '../../features/wallets/presentation/wallet_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPlaceholderScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: '/wallets',
        name: 'wallets',
        builder: (context, state) => const WalletListScreen(),
      ),
      GoRoute(
        path: '/wallets/add',
        name: 'add-wallet',
        builder: (context, state) => const AddWalletScreen(),
      ),
      GoRoute(
        path: '/wallets/:id/edit',
        name: 'edit-wallet',
        builder: (context, state) {
          final walletId = state.pathParameters['id']!;
          return EditWalletScreen(walletId: walletId);
        },
      ),
    ],
  );
});
