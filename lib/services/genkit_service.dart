import 'dart:convert';
import 'package:flutter/foundation.dart'; // Importar kIsWeb
import 'package:http/http.dart' as http;

/// Service class for interacting with the Genkit API server
class GenkitService {
  // Base URL for the Genkit API server
  // For local development, use http://10.0.2.2:3000 for Android emulator (mas estamos usando o IP real do host)
  // or http://localhost:3000 for web/iOS (quando o servidor Node.js está acessível via localhost pelo navegador)
  final String baseUrl;
  
  final http.Client _client = http.Client();
  
  GenkitService({String? baseUrl})
      // Substitua PELA_SUA_URL_DO_WEB_PREVIEW_PORTA_3000 pela URL HTTPS que o Cloud Shell Web Preview forneceu para a porta 3000
      : baseUrl = baseUrl ?? (kIsWeb ? 'PELA_SUA_URL_DO_WEB_PREVIEW_PORTA_3000' : 'http://10.88.0.3:3000');
  
  /// Test the hello flow with a name
  Future<String> testHelloFlow(String name) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/hello'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Connection timeout. Please check if the server is running and accessible at $baseUrl.');
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] is Map && data['result']['result'] != null) {
          return data['result']['result'];
        }
        return data['result']?.toString() ?? 'No result returned or unexpected format';
      } else {
        throw Exception('Failed to call hello flow: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calling hello flow: $e');
    }
  }
  
  /// Process an onboarding question answer
  Future<Map<String, dynamic>> processOnboardingAnswer(String answer) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/onboarding-question'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'answer': answer}),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Connection timeout. Please check if the server is running and accessible at $baseUrl.');
      });
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to process onboarding answer: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error processing onboarding answer: $e');
    }
  }
  
  /// Get habit suggestions based on user information
  Future<Map<String, dynamic>> getHabitSuggestions(Map<String, dynamic> userInfo) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/habit-suggestions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userInfo),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Connection timeout. Please check if the server is running and accessible at $baseUrl.');
      });
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get habit suggestions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting habit suggestions: $e');
    }
  }
}
