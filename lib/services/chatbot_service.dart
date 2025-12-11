import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  // ============================================
  // AI PROVIDER: OpenRouter
  // ============================================

  // OpenRouter API Key (Compatible with OpenAI format)
  static const String _openrouterKey =
      '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';
  static const String _openrouterUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  // Note: You can switch to other models via OpenRouter by changing the 'model' field

  // System prompt to guide AI behavior (customize for LeadUnity)
  static const String _systemPrompt =
      '''You are an AI assistant for LeadUnity, an educational platform for managing student proposals and team collaborations. 
Help students with:
- Project proposal guidance
- Team collaboration tips
- Academic writing assistance
- Project management advice
- General educational support

Be helpful, friendly, and concise. If asked about sensitive matters outside your scope, politely redirect.''';

  // ============================================
  // OpenRouter API (Supports multiple models)
  // ============================================
  static Future<String> chatWithOpenRouter(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_openrouterUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openrouterKey',
          'HTTP-Referer': 'https://example.com', // Required by OpenRouter
          'X-Title': 'LinkUnity',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // Can use 'gpt-4', 'claude-3-sonnet', etc.
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['choices'][0]['message']['content'].trim();
      } else {
        throw Exception(
            'OpenRouter Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get response from OpenRouter: $e');
    }
  }
}
