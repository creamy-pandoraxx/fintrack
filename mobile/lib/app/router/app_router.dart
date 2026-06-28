import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/activity_feed_screen.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/budgets/presentation/add_budget_screen.dart';
import '../../features/budgets/presentation/budget_list_screen.dart';
import '../../features/budgets/presentation/edit_budget_screen.dart';
import '../../features/categories/domain/category.dart';
import '../../features/categories/presentation/add_category_screen.dart';
import '../../features/categories/presentation/category_list_screen.dart';
import '../../features/categories/presentation/edit_category_screen.dart';
import '../../features/profile/presentation/profile_settings_screen.dart';
import '../../features/transactions/presentation/add_transaction_screen.dart';
import '../../features/transactions/presentation/edit_transaction_screen.dart';
import '../../features/transactions/presentation/transaction_detail_screen.dart';
import '../../features/transactions/presentation/transaction_list_screen.dart';
import '../../features/wallets/presentation/add_wallet_screen.dart';
import '../../features/wallets/presentation/edit_wallet_screen.dart';
import '../../features/wallets/presentation/wallet_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final authRefresh = _FirebaseAuthRefreshListenable(firebaseAuth);
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (!authRefresh.isReady) {
        return location == '/splash' ? null : '/splash';
      }

      if (firebaseAuth.currentUser == null &&
          !_publicRoutes.contains(location)) {
        return '/welcome';
      }

      return null;
    },
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
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: '/activity',
        name: 'activity-feed',
        builder: (context, state) => const ActivityFeedScreen(),
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
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoryListScreen(),
      ),
      GoRoute(
        path: '/categories/add',
        name: 'add-category',
        builder: (context, state) {
          final type = CategoryType.fromApiValue(
            state.uri.queryParameters['type'] ?? CategoryType.expense.apiValue,
          );
          return AddCategoryScreen(initialType: type);
        },
      ),
      GoRoute(
        path: '/categories/:id/edit',
        name: 'edit-category',
        builder: (context, state) {
          final categoryId = state.pathParameters['id']!;
          return EditCategoryScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: '/budgets',
        name: 'budgets',
        builder: (context, state) => const BudgetListScreen(),
      ),
      GoRoute(
        path: '/budgets/add',
        name: 'add-budget',
        builder: (context, state) {
          final now = DateTime.now();
          final month = int.tryParse(state.uri.queryParameters['month'] ?? '');
          final year = int.tryParse(state.uri.queryParameters['year'] ?? '');

          return AddBudgetScreen(
            initialMonth: month ?? now.month,
            initialYear: year ?? now.year,
          );
        },
      ),
      GoRoute(
        path: '/budgets/:id/edit',
        name: 'edit-budget',
        builder: (context, state) {
          final budgetId = state.pathParameters['id']!;
          return EditBudgetScreen(budgetId: budgetId);
        },
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionListScreen(),
      ),
      GoRoute(
        path: '/transactions/add',
        name: 'add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/transactions/:id/edit',
        name: 'edit-transaction',
        builder: (context, state) {
          final transactionId = state.pathParameters['id']!;
          return EditTransactionScreen(transactionId: transactionId);
        },
      ),
      GoRoute(
        path: '/transactions/:id',
        name: 'transaction-detail',
        builder: (context, state) {
          final transactionId = state.pathParameters['id']!;
          return TransactionDetailScreen(transactionId: transactionId);
        },
      ),
    ],
  );
});

const _publicRoutes = {'/', '/splash', '/welcome', '/login', '/register'};

class _FirebaseAuthRefreshListenable extends ChangeNotifier {
  _FirebaseAuthRefreshListenable(FirebaseAuth firebaseAuth) {
    _subscription = firebaseAuth.authStateChanges().listen(
      (_) {
        isReady = true;
        notifyListeners();
      },
      onError: (_) {
        isReady = true;
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<User?> _subscription;
  bool isReady = false;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
