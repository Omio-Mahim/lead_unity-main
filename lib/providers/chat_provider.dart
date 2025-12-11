import 'package:flutter/material.dart';
import 'package:link_unity/models/chat_message_model.dart';
import 'package:link_unity/services/chatbot_service.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with a welcome message (optional)
  ChatProvider() {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        id: 'welcome',
        content:
            'Hello! I\'m your LeadUnity AI Assistant. I can help you with project proposals, team collaboration, and academic guidance. What would you like to know?',
        isUserMessage: false,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // Send message to chatbot and get response
  Future<void> sendMessage(String userMessage, {String? userToken}) async {
    // Add user message to chat
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userMessage,
      isUserMessage: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call the chatbot service with OpenRouter
      String botResponse;
      botResponse = await ChatbotService.chatWithOpenRouter(userMessage);

      // Add bot response to chat
      final botMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: botResponse,
        isUserMessage: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botMsg);
    } catch (e) {
      _error = e.toString();
      // Add error message to chat
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error: $_error. Please try again.',
        isUserMessage: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear chat history
  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    _error = null;
    notifyListeners();
  }
}
