/// Service for handling chatbot responses
class ChatbotService {
  /// Get a response based on user input
  static String getResponse(String userMessage) {
    final message = userMessage.toLowerCase().trim();

    // Greetings
    if (_matches(message, ['hi', 'hello', 'hey', 'good morning', 'good afternoon', 'good evening'])) {
      return 'Hello! 👋 I\'m here to help you with your barangay concerns. How can I assist you today?';
    }

    // Help/What can you do
    if (_matches(message, ['help', 'what can you do', 'what do you do', 'features'])) {
      return 'I can help you with:\n\n'
          '📋 Report issues (garbage, streetlights, flooding)\n'
          '🚨 Emergency assistance information\n'
          '📊 Check your report status\n'
          '📢 View announcements\n'
          '❓ General questions about the barangay system\n\n'
          'Just ask me anything!';
    }

    // Report issues
    if (_matches(message, ['report', 'submit', 'file a report', 'report issue', 'how to report'])) {
      return 'To report an issue:\n\n'
          '1. Go to the "Report issue" section from the home screen\n'
          '2. Select the issue type (Garbage, Streetlight, Flooding, or Others)\n'
          '3. Add a description and location\n'
          '4. Attach photos if available\n'
          '5. Submit your report\n\n'
          'Your report will be reviewed by barangay officials.';
    }

    // Check reports
    if (_matches(message, ['my reports', 'check reports', 'report status', 'status', 'track'])) {
      return 'To check your reports:\n\n'
          '1. Go to "My reports" from the home screen\n'
          '2. You\'ll see all your submitted reports\n'
          '3. Each report shows its current status:\n'
          '   • Pending - Awaiting review\n'
          '   • In Progress - Being addressed\n'
          '   • Resolved - Completed\n\n'
          'You can tap on any report to see more details.';
    }

    // Emergency
    if (_matches(message, ['emergency', 'emergency help', 'urgent', 'fire', 'police', 'health', 'ambulance'])) {
      return 'For emergencies:\n\n'
          '🚨 Go to the "Emergency" section from the home screen\n'
          '🚨 Select the type of emergency:\n'
          '   • Health - Medical emergencies\n'
          '   • Fire - Fire department\n'
          '   • Police - Law enforcement\n\n'
          'You can contact emergency services directly from the app.';
    }

    // Announcements
    if (_matches(message, ['announcements', 'news', 'updates', 'notices'])) {
      return 'To view announcements:\n\n'
          '📢 Check the "Announcements" section on your home screen\n'
          '📢 You can see the latest barangay updates and notices\n'
          '📢 Tap "View all" to see the complete list\n\n'
          'Stay informed about important community news!';
    }

    // Issue types
    if (_matches(message, ['garbage', 'trash', 'waste', 'litter'])) {
      return 'For garbage issues:\n\n'
          '🗑️ Report garbage collection problems\n'
          '🗑️ Report illegal dumping\n'
          '🗑️ Request waste management services\n\n'
          'Go to "Report issue" and select "Garbage" as the issue type.';
    }

    if (_matches(message, ['streetlight', 'light', 'lighting', 'lamp', 'dark'])) {
      return 'For streetlight issues:\n\n'
          '💡 Report broken or non-working streetlights\n'
          '💡 Request new streetlight installation\n'
          '💡 Report areas that need better lighting\n\n'
          'Go to "Report issue" and select "Streetlight" as the issue type.';
    }

    if (_matches(message, ['flood', 'flooding', 'water', 'drainage'])) {
      return 'For flooding issues:\n\n'
          '🌊 Report flooding in your area\n'
          '🌊 Report drainage problems\n'
          '🌊 Request flood prevention measures\n\n'
          'Go to "Report issue" and select "Flooding" as the issue type.';
    }

    // Status questions
    if (_matches(message, ['pending', 'in progress', 'resolved', 'what does pending mean'])) {
      return 'Report Status Meanings:\n\n'
          '⏳ Pending - Your report has been submitted and is waiting for review by barangay officials.\n\n'
          '🔄 In Progress - Your report is being actively addressed by the barangay team.\n\n'
          '✅ Resolved - Your issue has been fixed or addressed. Thank you for your report!';
    }

    // Thank you
    if (_matches(message, ['thank', 'thanks', 'thank you', 'appreciate'])) {
      return 'You\'re welcome! 😊 If you need any other help, just ask. I\'m here 24/7!';
    }

    // Goodbye
    if (_matches(message, ['bye', 'goodbye', 'see you', 'later'])) {
      return 'Goodbye! 👋 Have a great day and stay safe!';
    }

    // Default response
    return 'I understand you\'re asking about "$userMessage". '
        'I can help you with:\n\n'
        '• Reporting issues\n'
        '• Checking report status\n'
        '• Emergency assistance\n'
        '• Viewing announcements\n\n'
        'Could you rephrase your question, or type "help" to see what I can do?';
  }

  /// Check if message matches any of the keywords
  static bool _matches(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }
}

