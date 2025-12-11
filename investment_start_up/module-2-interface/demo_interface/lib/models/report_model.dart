// lib/models/report_model.dart

class ReportModel {
  final String id;
  final String title;
  final DateTime createdAt; // Fecha de creación del reporte
  
  // Campos de Predicción y Archivo
  final String reportFile; // Nombre del archivo PDF (report_url)
  final String predictionResult; // Ejemplo: 'IPO' o 'NO IPO'
  final double confidence; // Nivel de confianza del modelo
  
  // En esta versión no tenemos el JSON completo de entrada en la tabla "reports",
  // así que dejamos este mapa opcional o vacío.
  final Map<String, dynamic> data;

  ReportModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.reportFile,
    required this.predictionResult,
    required this.confidence,
    required this.data,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // Función auxiliar para parsear la fecha (maneja strings de fecha)
    DateTime parseDate(dynamic date) {
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (_) {
          // Si el parseo falla, retorna la fecha actual como fallback
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return ReportModel(
      // Coincide con las columnas reales insertadas por FastAPI en la tabla 'reports'
      id: (json['reportid'] ?? '').toString(),
      // Usamos el nombre de la startup como título si existe, si no un valor genérico
      title: (json['start_up_name'] ?? 'IPO Report').toString(),
      // La columna guardada en FastAPI es 'creation-date'
      createdAt: parseDate(json['creation-date']), 
      
      // Mapeo de los campos de predicción/archivo según main.py
      reportFile: (json['report_url'] ?? '').toString(),
      predictionResult: (json['IPO_NO IPO'] ?? '').toString(),
      // Usamos 'num' para manejar de forma segura tanto int como double que vienen del JSON
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      
      // No almacenamos el JSON completo de entrada en la tabla 'reports',
      // así que devolvemos un mapa vacío para evitar nulls.
      data: (json['data'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );
  }
}
