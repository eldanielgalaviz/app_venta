import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendify/models/user.dart';
import 'package:vendify/services/database_helper.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');
      
      if (userId != null) {
        final db = await DatabaseHelper().database;
        final result = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
        );
        
        if (result.isNotEmpty) {
          _currentUser = User.fromJson(result.first);
          _isAuthenticated = true;
          notifyListeners();
        }
      } else {
        // Auto-login as Guest Admin for demo purposes
        _currentUser = User(
          id: 0,
          username: 'admin',
          password: '',
          role: 'Administrador',
          fullName: 'Admin (Demo)',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing auth service: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (result.isNotEmpty) {
        _currentUser = User.fromJson(result.first);
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('current_user_id', _currentUser!.id!);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error during login: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  bool isAdmin() => _currentUser?.role == 'Administrador';
}
