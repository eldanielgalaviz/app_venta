import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vendify/screens/login_screen.dart';
import 'package:vendify/screens/dashboard_screen.dart';
import 'package:vendify/screens/products_screen.dart';
import 'package:vendify/screens/pos_screen.dart';
import 'package:vendify/screens/sales_history_screen.dart';
import 'package:vendify/screens/reports_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ProductsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.pos,
        name: 'pos',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: PosScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.salesHistory,
        name: 'sales-history',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SalesHistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ReportsScreen(),
        ),
      ),
    ],
  );
}

class AppRoutes {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String pos = '/pos';
  static const String salesHistory = '/sales-history';
  static const String reports = '/reports';
}
