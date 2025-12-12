import 'package:flutter/foundation.dart';
import '../services/chatbot_service.dart';

/// Model for chat messages
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Provider for managing chatbot state
class ChatbotProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatbotProvider() {
    // Add welcome message
    _addBotMessage('Hello! 👋 I\'m your Barangay Assistant. How can I help you today?');
  }

  /// Add a user message and get bot response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _addUserMessage(text);

    // Show loading
    _isLoading = true;
    notifyListeners();

    // Simulate thinking delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    // Get bot response
    final response = _getBotResponse(text);

    _isLoading = false;
    _addBotMessage(response);
  }

  /// Add user message to chat
  void _addUserMessage(String text) {
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Add bot message to chat
  void _addBotMessage(String text) {
    _messages.add(ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Get bot response using chatbot service
  String _getBotResponse(String userMessage) {
    return ChatbotService.getResponse(userMessage);
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    _addBotMessage('Hello! 👋 I\'m your Barangay Assistant. How can I help you today?');
    notifyListeners();
  }
}

