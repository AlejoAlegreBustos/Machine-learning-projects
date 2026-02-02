import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  /// LOGIN
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await client
          .from('user')
          .select('user_id, password, email, uname, lname')
          .eq('email', email)
          .maybeSingle();

      debugPrint('Response from Supabase: $response');

      if (response == null) {
        debugPrint('Email not found');
        return null;
      }

      // ⚠ Para producción: usar hash en lugar de texto plano
      if (response['password'] == password) {
        debugPrint('Login successful');

        // Convertimos la respuesta en UserModel
        return UserModel(
          id: response['user_id'],
          name: response['uname'] ?? "User",
          lastName: response['lname'] ?? "",
          email: response['email'] ?? "",
        );
      } else {
        debugPrint('Password incorrect');
        return null;
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      return null;
    }
  }

  /// GET PROFILE (si lo necesitaras)
  Future<UserModel?> getUserProfile(String email) async {
    try {
      final response = await client
          .from('user')
          .select('user_id, email, uname, lname')
          .eq('email', email)
          .maybeSingle();

      debugPrint('Profile response: $response');

      if (response == null) return null;

      return UserModel(
        id: response['user_id'],
        name: response['uname'] ?? "",
        lastName: response['lname'] ?? "",
        email: response['email'] ?? "",
      );
    } catch (e) {
      debugPrint("Profile error: $e");
      return null;
    }
  }
}
