import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/report_model.dart';
import '../services/api_service.dart'; // Asegúrate de tener esta importación
class ReportsProvider extends ChangeNotifier {
  // Instancia del ApiService para la descarga
  final ApiService _apiService = ApiService(); 

  final List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _errorMessage; // Nuevo campo para manejar errores

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage; // Getter para el error

  // --- 1. Lógica para cargar reportes (desde Supabase) ---
  Future<void> loadReports(String userId) async {
    _isLoading = true;
    _errorMessage = null; // Limpiar error anterior
    notifyListeners();

    try {
      final res = await Supabase.instance.client
          .from('reports')
          .select()
          .eq('user_id', userId)
          // La columna creada en FastAPI es 'creation-date', no 'created_at'.
          // Si prefieres evitar errores por nombre de columna, puedes quitar el order().
          .order('creation-date', ascending: false);

      _reports.clear();
      for (var item in res) {
        // ReportModel.fromJson ahora está alineado con el esquema real de la tabla 'reports'
        _reports.add(ReportModel.fromJson(item)); 
      }

    } on PostgrestException catch (e) {
      _errorMessage = 'Database Error: ${e.message}';
      debugPrint("Supabase Error: $e");
    } catch (e) {
      _errorMessage = 'Error fetching reports: $e';
      debugPrint("General Error fetching reports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. Lógica para descargar reportes (desde FastAPI) ---
  Future<void> downloadReport(String filename) async {
    try {
      final url = Uri.parse('${_apiService.baseUrl}/download/$filename');

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (kDebugMode) {
          debugPrint('PDF abierto en el navegador: $url');
        }
      } else {
        _errorMessage = 'No se pudo abrir la URL de descarga: $url';
        debugPrint(_errorMessage);
      }
    } catch (e) {
      // Manejar errores de conexión o del servidor FastAPI
      _errorMessage = 'Error downloading report: ${e.toString()}';
      debugPrint('Download Error: $e');
    }
    // No notificamos listeners después de la descarga a menos que queramos mostrar 
    // el estado de la descarga en la UI, lo cual es opcional.
  }
}
