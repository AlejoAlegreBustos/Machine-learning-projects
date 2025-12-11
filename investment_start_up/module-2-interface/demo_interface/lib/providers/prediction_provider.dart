import 'package:flutter/foundation.dart';
import 'package:demo_interface/models/prediction_result.dart';
import 'package:demo_interface/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
class PredictionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  PredictionResult? _predictionResult; // Resultado temporal de la predicción
  bool _isLoading = false;
  String? _errorMessage;
  String? _saveMessage; // Mensaje para notificar el éxito/fallo al guardar

  // Getters
  PredictionResult? get predictionResult => _predictionResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get saveMessage => _saveMessage;

  // Reinicia los estados de la predicción
  void resetPredictionState() {
    _predictionResult = null;
    _errorMessage = null;
    _saveMessage = null;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // 1. Obtiene la predicción de FastAPI (NO GUARDA en DB todavía)
  // ------------------------------------------------------------------
  Future<void> fetchPrediction(
    List<double> features,
    String userId,
    String startupName,
  ) async {
    // Validación opcional de userId (ya no se envía al modelo, pero se usa para guardar luego)
    if (userId == 'default-anonymous-id' || userId.isEmpty) {
      _errorMessage = 'Error: No se pudo obtener el ID del usuario. Por favor, inicie sesión correctamente.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _saveMessage = null;
    notifyListeners();

    try {
      // Llama a la API y el resultado se mapea a PredictionResult
      final result = await _apiService.getPrediction(
        features,
        userId,
        startupName,
      );
      _predictionResult = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Fallo al obtener la predicción: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('Prediction Error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------------
  // 2. Marca explícitamente el reporte como "guardado" (Llamado por el usuario)
  //    El backend ya guarda el reporte en Supabase dentro de /predict,
  //    así que aquí solo actualizamos el estado de la UI.
  // ------------------------------------------------------------------
  Future<bool> saveReport(String userId) async {
    if (_predictionResult == null) {
      _saveMessage = 'No predictions to save.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _saveMessage = null;
    notifyListeners();

    // En esta versión no hacemos otra llamada HTTP porque /predict ya
    // insertó el reporte en la tabla "reports" de Supabase.
    _saveMessage = '¡Report save on my reports page!';
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ------------------------------------------------------------------
  // 3. Descarga de Reporte
  // ------------------------------------------------------------------
  Future<void> downloadReport(String filename) async {
    try {
      final url = Uri.parse('${_apiService.baseUrl}/download/$filename');

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (kDebugMode) {
          debugPrint('Report opened on browser: $url');
        }
      } else {
        debugPrint('Download failed: $url');
      }
    } catch (e) {
      debugPrint('Error trying to download report: $e');
    }
  }
}
