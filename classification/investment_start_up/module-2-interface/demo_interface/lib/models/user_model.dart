class UserModel {
  final String id; // Supabase user_id
  String name; // nombre visible del usuario
  String? avatarUrl; // URL del avatar (opcional)
  String? lastName; // apellido opcional
  String? email; // email opcional
  String? reportId; // id de reporte opcional

  UserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.lastName,
    this.email,
    this.reportId,
  });

  /// Constructor desde mapa (ej. respuesta de Supabase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['user_id'].toString(),
      name: map['uname'] ?? "User",
      avatarUrl: map['avatar_url'], // si existe en la base
      lastName: map['lname'],
      email: map['email'],
      reportId: map['reportid']?.toString(),
    );
  }

  /// Método para actualizar desde otro mapa parcial
  void updateFromMap(Map<String, dynamic> map) {
    if (map.containsKey('uname')) name = map['uname'];
    if (map.containsKey('avatar_url')) avatarUrl = map['avatar_url'];
    if (map.containsKey('lname')) lastName = map['lname'];
    if (map.containsKey('email')) email = map['email'];
    if (map.containsKey('reportid')) reportId = map['reportid']?.toString();
  }
}
