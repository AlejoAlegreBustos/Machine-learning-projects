import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  // Inicializa con valores por defecto si no hay usuario aún
  UserModel _user = UserModel(id: '0', name: 'User');

  UserModel get user => _user;

  // Permite actualizar todo el usuario
  void setUser(UserModel newUser) {
    _user = newUser;
    notifyListeners();
  }

  // Actualiza solo el nombre
  void setName(String newName) {
    _user.name = newName;
    notifyListeners();
  }

  // Actualiza avatar opcionalmente
  void setAvatar(String newAvatarUrl) {
    _user.avatarUrl = newAvatarUrl;
    notifyListeners();
  }
}
