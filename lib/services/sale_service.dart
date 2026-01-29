import 'package:flutter/foundation.dart';
import 'package:vendify/models/sale.dart';
import 'package:vendify/models/sale_detail.dart';
import 'package:vendify/services/database_helper.dart';

class SaleService extends ChangeNotifier {
  List<Sale> _sales = [];
  Map<int, List<SaleDetail>> _saleDetails = {};

  List<Sale> get sales => _sales;

  Future<void> loadSales() async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query('sales', orderBy: 'created_at DESC');
      _sales = result.map((json) => Sale.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading sales: $e');
    }
  }

  Future<List<SaleDetail>> getSaleDetails(int saleId) async {
    if (_saleDetails.containsKey(saleId)) {
      return _saleDetails[saleId]!;
    }

    try {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'sale_details',
        where: 'sale_id = ?',
        whereArgs: [saleId],
      );
      
      final details = result.map((json) => SaleDetail.fromJson(json)).toList();
      _saleDetails[saleId] = details;
      return details;
    } catch (e) {
      debugPrint('Error loading sale details: $e');
      return [];
    }
  }

  Future<int?> createSale(Sale sale, List<SaleDetail> details) async {
    try {
      final db = await DatabaseHelper().database;
      
      final saleId = await db.insert('sales', sale.toJson());
      
      for (var detail in details) {
        await db.insert('sale_details', detail.copyWith(saleId: saleId).toJson());
      }
      
      await loadSales();
      debugPrint('Sale created with id: $saleId');
      return saleId;
    } catch (e) {
      debugPrint('Error creating sale: $e');
      return null;
    }
  }

  List<Sale> getSalesByDateRange(DateTime start, DateTime end) {
    return _sales.where((sale) {
      final saleDate = sale.createdAt;
      return saleDate.isAfter(start.subtract(const Duration(days: 1))) &&
             saleDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotalSalesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final daySales = _sales.where((sale) {
      final saleDate = sale.createdAt;
      return saleDate.isAfter(startOfDay) && saleDate.isBefore(endOfDay);
    });
    
    return daySales.fold(0.0, (sum, sale) => sum + sale.total);
  }

  int getSalesCountByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _sales.where((sale) {
      final saleDate = sale.createdAt;
      return saleDate.isAfter(startOfDay) && saleDate.isBefore(endOfDay);
    }).length;
  }

  double getCashSalesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final cashSales = _sales.where((sale) {
      final saleDate = sale.createdAt;
      return sale.paymentMethod == 'Efectivo' &&
             saleDate.isAfter(startOfDay) &&
             saleDate.isBefore(endOfDay);
    });
    
    return cashSales.fold(0.0, (sum, sale) => sum + sale.total);
  }
}
