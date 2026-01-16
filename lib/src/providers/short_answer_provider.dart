// Short Answer Provider
// Manages state for AI short answer feature

import 'package:flutter/material.dart';
import '../services/ai_short_answer_service.dart';

class ShortAnswerProvider with ChangeNotifier {
  final AIShortAnswerService _aiService = AIShortAnswerService();

  // State variables
  String _currentQuery = '';
  String _aiResponse = '';
  AnswerType _selectedType = AnswerType.definition;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  List<String> _recentQueries = [];
  List<String> _relatedTerms = [];

  // Getters
  String get currentQuery => _currentQuery;
  String get aiResponse => _aiResponse;
  AnswerType get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  List<String> get recentQueries => _recentQueries;
  List<String> get relatedTerms => _relatedTerms;

  // Setters
  void setQuery(String query) {
    _currentQuery = query;
    notifyListeners();
  }

  void setAnswerType(AnswerType type) {
    _selectedType = type;
    notifyListeners();
  }

  // Generate AI response
  Future<void> generateAnswer() async {
    if (_currentQuery.isEmpty) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // Generate AI response
      final response = await _aiService.generateShortAnswer(
        query: _currentQuery,
        type: _selectedType,
        maxLength: 200,
      );

      _aiResponse = response;

      // Add to recent queries
      if (!_recentQueries.contains(_currentQuery)) {
        _recentQueries.insert(0, _currentQuery);
        if (_recentQueries.length > 10) {
          _recentQueries.removeLast();
        }
      }

      // Get related terms
      _relatedTerms = await _aiService.getRelatedTerms(_currentQuery);

    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to generate response: $e';
      _aiResponse = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear current response
  void clearResponse() {
    _aiResponse = '';
    _hasError = false;
    notifyListeners();
  }

  // Load a recent query
  void loadRecentQuery(String query) {
    _currentQuery = query;
    notifyListeners();
    generateAnswer();
  }

  // Copy response to clipboard
  Future<void> copyToClipboard(BuildContext context) async {
    if (_aiResponse.isNotEmpty) {
      // Implementation depends on your clipboard package
      // Example: await Clipboard.setData(ClipboardData(text: _aiResponse));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Response copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}