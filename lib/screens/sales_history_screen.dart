import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vendify/models/sale.dart';
import 'package:vendify/models/sale_detail.dart';
import 'package:vendify/services/sale_service.dart';
import 'package:vendify/theme.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleService>().loadSales();
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  void _showSaleDetails(Sale sale) async {
    final details = await context.read<SaleService>().getSaleDetails(sale.id!);
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaleDetailsDialog(sale: sale, details: details),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textStyles;
    final saleService = context.watch<SaleService>();
    
    final sales = _startDate != null && _endDate != null
        ? saleService.getSalesByDateRange(_startDate!, _endDate!)
        : saleService.sales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        actions: [
          IconButton(
            icon: Icon(
              _startDate != null ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _startDate != null ? colorScheme.secondary : null,
            ),
            onPressed: _selectDateRange,
          ),
          if (_startDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateFilter,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_startDate != null && _endDate != null)
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              color: colorScheme.secondaryContainer,
              child: Text(
                'Filtrado: ${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          Expanded(
            child: sales.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No hay ventas registradas',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: AppSpacing.paddingMd,
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return SaleCard(
                        sale: sale,
                        onTap: () => _showSaleDetails(sale),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SaleCard extends StatelessWidget {
  final Sale sale;
  final VoidCallback onTap;

  const SaleCard({
    super.key,
    required this.sale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textStyles;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.receipt,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket #${sale.id}',
                      style: textTheme.titleMedium?.semiBold,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: sale.paymentMethod == 'Efectivo'
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        sale.paymentMethod,
                        style: textTheme.bodySmall?.copyWith(
                          color: sale.paymentMethod == 'Efectivo'
                              ? Colors.green
                              : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${sale.total.toStringAsFixed(2)}',
                    style: textTheme.titleLarge?.semiBold.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SaleDetailsDialog extends StatelessWidget {
  final Sale sale;
  final List<SaleDetail> details;

  const SaleDetailsDialog({
    super.key,
    required this.sale,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textStyles;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: AppSpacing.paddingLg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ticket #${sale.id}',
                style: textTheme.titleLarge?.semiBold,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'Pago: ${sale.paymentMethod}',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: AppSpacing.lg),
          Text(
            'Productos',
            style: textTheme.titleMedium?.semiBold,
          ),
          const SizedBox(height: AppSpacing.md),
          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.productName,
                        style: textTheme.bodyMedium?.semiBold,
                      ),
                      Text(
                        '${detail.quantity} x \$${detail.unitPrice.toStringAsFixed(2)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${detail.subtotal.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.semiBold,
                ),
              ],
            ),
          )),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:', style: textTheme.bodyMedium),
              Text('\$${sale.subtotal.toStringAsFixed(2)}', style: textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('IVA:', style: textTheme.bodyMedium),
              Text('\$${sale.tax.toStringAsFixed(2)}', style: textTheme.bodyMedium),
            ],
          ),
          const Divider(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: textTheme.titleLarge?.semiBold),
              Text(
                '\$${sale.total.toStringAsFixed(2)}',
                style: textTheme.titleLarge?.semiBold.copyWith(
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
