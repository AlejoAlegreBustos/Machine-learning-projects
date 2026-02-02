import 'package:flutter/material.dart';
import '../models/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile? _user;

  UserProfile? get user => _user;

  // Simulación de carga de datos (reemplazar por Firebase o API)
  Future<void> loadUserProfile() async {
    // Aquí iría tu fetch real
    _user = UserProfile(
      name: "Alejo Alegre",
      email: "alejo@example.com",
      avatarUrl: "https://via.placeholder.com/150",
    );

    notifyListeners();
  }

  // Método para actualizar el nombre (opcional)
  void updateName(String newName) {
    if (_user != null) {
      _user = UserProfile(
        name: newName,
        email: _user!.email,
        avatarUrl: _user!.avatarUrl,
      );
      notifyListeners();
    }
  }
}
