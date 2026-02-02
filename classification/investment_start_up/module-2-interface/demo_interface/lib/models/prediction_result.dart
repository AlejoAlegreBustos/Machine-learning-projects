class PredictionResult {
  // Predicción cruda del modelo (0 o 1)
  final int prediction;
  // Texto legible para mostrar en UI (ej: 'IPO' o 'NO IPO')
  final String result;
  final double confidence;
  final String reportFile;

  PredictionResult({
    required this.prediction,
    required this.result,
    required this.confidence,
    required this.reportFile,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final int pred = json['prediction'] as int;
    final String derivedLabel = pred == 1 ? 'IPO' : 'NO IPO';

    return PredictionResult(
      prediction: pred,
      // El backend actual devuelve 'prediction', 'confidence', 'report_file'
      // así que derivamos el texto a partir de prediction.
      result: derivedLabel,
      confidence: (json['confidence'] as num).toDouble(),
      reportFile: json['report_file'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'result': result,
      'confidence': confidence,
      'report_file': reportFile,
    };
  }
}
