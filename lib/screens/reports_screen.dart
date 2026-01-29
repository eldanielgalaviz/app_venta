import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vendify/services/report_service.dart';
import 'package:vendify/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _reportService = ReportService();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  
  double _totalRevenue = 0.0;
  List<TopProduct> _topProducts = [];
  Map<String, double> _salesByPayment = {};

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    _totalRevenue = await _reportService.getTotalRevenue(
      startDate: _startDate,
      endDate: _endDate,
    );

    _topProducts = await _reportService.getTopProducts(
      startDate: _startDate,
      endDate: _endDate,
      limit: 10,
    );

    _salesByPayment = await _reportService.getSalesByPaymentMethod(
      startDate: _startDate,
      endDate: _endDate,
    );

    setState(() => _isLoading = false);
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
      _loadReports();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textStyles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: Icon(
              _startDate != null ? Icons.date_range : Icons.date_range_outlined,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_startDate != null && _endDate != null)
                    Container(
                      width: double.infinity,
                      padding: AppSpacing.paddingMd,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Periodo',
                            style: textTheme.titleSmall?.semiBold,
                          ),
                          Text(
                            '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: AppSpacing.paddingLg,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Ingresos Totales',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '\$${_totalRevenue.toStringAsFixed(2)}',
                          style: textTheme.displaySmall?.semiBold.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Ventas por Método de Pago',
                    style: textTheme.titleLarge?.semiBold,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_salesByPayment.isEmpty)
                    Center(
                      child: Text(
                        'No hay datos disponibles',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ..._salesByPayment.entries.map((entry) => Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: Icon(
                          entry.key == 'Efectivo' ? Icons.payments : Icons.credit_card,
                          color: entry.key == 'Efectivo' ? Colors.green : Colors.blue,
                        ),
                        title: Text(entry.key),
                        trailing: Text(
                          '\$${entry.value.toStringAsFixed(2)}',
                          style: textTheme.titleMedium?.semiBold,
                        ),
                      ),
                    )),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Productos Más Vendidos',
                    style: textTheme.titleLarge?.semiBold,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_topProducts.isEmpty)
                    Center(
                      child: Text(
                        'No hay datos disponibles',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ..._topProducts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.tertiaryContainer,
                            child: Text(
                              '${index + 1}',
                              style: textTheme.titleMedium?.semiBold.copyWith(
                                color: colorScheme.tertiary,
                              ),
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            'Cantidad vendida: ${product.quantitySold}',
                            style: textTheme.bodySmall,
                          ),
                          trailing: Text(
                            '\$${product.totalRevenue.toStringAsFixed(2)}',
                            style: textTheme.titleMedium?.semiBold.copyWith(
                              color: colorScheme.secondary,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
