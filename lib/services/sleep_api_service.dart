import 'dart:convert';
import 'package:http/http.dart' as http;

class SleepPrediction {
  final String prediction;
  final double confidence;

  SleepPrediction({required this.prediction, required this.confidence});

  factory SleepPrediction.fromJson(Map<String, dynamic> json) {
    return SleepPrediction(
      prediction: json['prediction'] ?? 'unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class SleepApiService {
  static const String _baseUrl = 'https://eranda-sathsara-javi.hf.space/predict';

  Future<SleepPrediction?> predict({required double motion, required double heartRate}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'motion': motion,
          'heart_rate': heartRate,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SleepPrediction.fromJson(data);
      }
    } catch (e) {
      print('Sleep API error: $e');
    }
    return null;
  }
}
