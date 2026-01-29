import 'package:flutter/foundation.dart';
import 'package:vendify/models/product.dart';
import 'package:vendify/models/category.dart' as model;
import 'package:vendify/services/database_helper.dart';

class ProductService extends ChangeNotifier {
  List<Product> _products = [];
  List<model.Category> _categories = [];

  List<Product> get products => _products;
  List<model.Category> get categories => _categories;

  Future<void> loadProducts() async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query('products', orderBy: 'name ASC');
      _products = result.map((json) => Product.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query('categories', orderBy: 'name ASC');
      _categories = result.map((json) => model.Category.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<bool> createProduct(Product product) async {
    try {
      final db = await DatabaseHelper().database;
      final id = await db.insert('products', product.toJson());
      await loadProducts();
      debugPrint('Product created with id: $id');
      return true;
    } catch (e) {
      debugPrint('Error creating product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final db = await DatabaseHelper().database;
      await db.update(
        'products',
        product.toJson(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      await loadProducts();
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final db = await DatabaseHelper().database;
      await db.delete('products', where: 'id = ?', whereArgs: [id]);
      await loadProducts();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  Future<bool> updateStock(int productId, int quantity) async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
      );
      
      if (result.isNotEmpty) {
        final product = Product.fromJson(result.first);
        final newStock = product.stock - quantity;
        
        await db.update(
          'products',
          {'stock': newStock, 'updated_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [productId],
        );
        
        await loadProducts();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating stock: $e');
      return false;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = query.toLowerCase();
    return _products.where((p) =>
      p.name.toLowerCase().contains(lowerQuery) ||
      p.sku.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  String getCategoryName(int categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId).name;
    } catch (e) {
      return 'Sin categoría';
    }
  }
}
