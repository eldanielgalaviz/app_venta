import 'package:flutter/foundation.dart';
import 'package:vendify/services/database_helper.dart';

class TopProduct {
  final String name;
  final int quantitySold;
  final double totalRevenue;

  TopProduct({
    required this.name,
    required this.quantitySold,
    required this.totalRevenue,
  });
}

class ReportService {
  Future<List<TopProduct>> getTopProducts({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  }) async {
    try {
      final db = await DatabaseHelper().database;
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (startDate != null && endDate != null) {
        whereClause = 'WHERE s.created_at >= ? AND s.created_at <= ?';
        whereArgs = [
          startDate.toIso8601String(),
          endDate.add(const Duration(days: 1)).toIso8601String(),
        ];
      }
      
      final result = await db.rawQuery('''
        SELECT 
          sd.product_name as name,
          SUM(sd.quantity) as quantity_sold,
          SUM(sd.subtotal) as total_revenue
        FROM sale_details sd
        JOIN sales s ON sd.sale_id = s.id
        $whereClause
        GROUP BY sd.product_id, sd.product_name
        ORDER BY quantity_sold DESC
        LIMIT ?
      ''', [...whereArgs, limit]);
      
      return result.map((row) => TopProduct(
        name: row['name'] as String,
        quantitySold: row['quantity_sold'] as int,
        totalRevenue: (row['total_revenue'] as num).toDouble(),
      )).toList();
    } catch (e) {
      debugPrint('Error getting top products: $e');
      return [];
    }
  }

  Future<Map<String, double>> getSalesByPaymentMethod({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await DatabaseHelper().database;
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (startDate != null && endDate != null) {
        whereClause = 'WHERE created_at >= ? AND created_at <= ?';
        whereArgs = [
          startDate.toIso8601String(),
          endDate.add(const Duration(days: 1)).toIso8601String(),
        ];
      }
      
      final result = await db.rawQuery('''
        SELECT payment_method, SUM(total) as total
        FROM sales
        $whereClause
        GROUP BY payment_method
      ''', whereArgs);
      
      return Map.fromEntries(
        result.map((row) => MapEntry(
          row['payment_method'] as String,
          (row['total'] as num).toDouble(),
        ))
      );
    } catch (e) {
      debugPrint('Error getting sales by payment method: $e');
      return {};
    }
  }

  Future<double> getTotalRevenue({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await DatabaseHelper().database;
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (startDate != null && endDate != null) {
        whereClause = 'WHERE created_at >= ? AND created_at <= ?';
        whereArgs = [
          startDate.toIso8601String(),
          endDate.add(const Duration(days: 1)).toIso8601String(),
        ];
      }
      
      final result = await db.rawQuery('''
        SELECT SUM(total) as total
        FROM sales
        $whereClause
      ''', whereArgs);
      
      if (result.isNotEmpty && result.first['total'] != null) {
        return (result.first['total'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      debugPrint('Error getting total revenue: $e');
      return 0.0;
    }
  }
}
