import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vendify/services/auth_service.dart';
import 'package:vendify/services/sale_service.dart';
import 'package:vendify/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleService>().loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textStyles;
    final authService = context.watch<AuthService>();
    final saleService = context.watch<SaleService>();

    final today = DateTime.now();
    final todayTotal = saleService.getTotalSalesByDate(today);
    final todayCount = saleService.getSalesCountByDate(today);
    final todayCash = saleService.getCashSalesByDate(today);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            Text(
              authService.currentUser?.fullName ?? '',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colorScheme.error),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Hoy',
              style: textTheme.titleLarge?.semiBold,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    icon: Icons.attach_money,
                    title: 'Total Vendido',
                    value: '\$${todayTotal.toStringAsFixed(2)}',
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DashboardCard(
                    icon: Icons.receipt_long,
                    title: 'Tickets',
                    value: todayCount.toString(),
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DashboardCard(
              icon: Icons.payments,
              title: 'Efectivo',
              value: '\$${todayCash.toStringAsFixed(2)}',
              color: Colors.green,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Accesos Rápidos',
              style: textTheme.titleLarge?.semiBold,
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.3,
              children: [
                QuickAccessCard(
                  icon: Icons.shopping_cart,
                  label: 'Nueva Venta',
                  color: colorScheme.primary,
                  onTap: () => context.push('/pos'),
                ),
                QuickAccessCard(
                  icon: Icons.inventory_2,
                  label: 'Productos',
                  color: colorScheme.secondary,
                  onTap: () => context.push('/products'),
                ),
                QuickAccessCard(
                  icon: Icons.history,
                  label: 'Historial',
                  color: colorScheme.tertiary,
                  onTap: () => context.push('/sales-history'),
                ),
                QuickAccessCard(
                  icon: Icons.bar_chart,
                  label: 'Reportes',
                  color: Colors.purple,
                  onTap: () => context.push('/reports'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: textTheme.headlineSmall?.semiBold.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: textTheme.titleMedium?.semiBold.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
