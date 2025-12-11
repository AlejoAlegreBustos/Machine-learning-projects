import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

class LoginProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? currentUser;
  UserModel? get user => currentUser;

  /// Login: devuelve true si es correcto y guarda el usuario en currentUser
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await _service.login(email.trim(), password.trim());

    _isLoading = false;

    if (user != null) {
      currentUser = user;
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  /// Logout: limpia currentUser
  void logout() {
    currentUser = null;
    notifyListeners();
  }
}
