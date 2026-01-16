// AI Short Answer Screen
// Main interface for quick AI definitions and summaries

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/short_answer_provider.dart';
import '../services/ai_short_answer_service.dart';
import '../components/ai_response_card.dart';

class AIShortAnswerScreen extends StatefulWidget {
  const AIShortAnswerScreen({super.key});

  @override
  State<AIShortAnswerScreen> createState() => _AIShortAnswerScreenState();
}

class _AIShortAnswerScreenState extends State<AIShortAnswerScreen> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focus on query field when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queryFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _queryFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('AI Short Answer'),
        backgroundColor: const Color(0xFF4361EE),
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistoryDialog,
            tooltip: 'Recent Queries',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ShortAnswerProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  // Search Section
                  _buildSearchSection(context, provider),

                  const SizedBox(height: 20),

                  // Answer Type Selector
                  _buildTypeSelector(provider),

                  const SizedBox(height: 24),

                  // AI Response Card
                  Expanded(
                    child: AIResponseCard(
                      response: provider.aiResponse,
                      isLoading: provider.isLoading,
                      hasError: provider.hasError,
                      errorMessage: provider.errorMessage,
                      onCopy: () => provider.copyToClipboard(context),
                      onRegenerate: provider.generateAnswer,
                    ),
                  ),

                  // Related Terms (if available)
                  if (provider.relatedTerms.isNotEmpty && provider.aiResponse.isNotEmpty)
                    _buildRelatedTermsSection(provider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, ShortAnswerProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask AI for Quick Answers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Get instant definitions, summaries, or explanations',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 16),

            // Query Input
            TextField(
              controller: _queryController,
              focusNode: _queryFocusNode,
              decoration: InputDecoration(
                hintText: 'e.g., Machine Learning, Flutter, Algorithm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) {
                provider.setQuery(value);
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  provider.generateAnswer();
                }
              },
            ),

            const SizedBox(height: 12),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.currentQuery.isEmpty || provider.isLoading
                    ? null
                    : provider.generateAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Generate AI Response',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(ShortAnswerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Response Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212529),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildTypeChip(
                'Definition',
                AnswerType.definition,
                Icons.assignment,
                provider,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _buildTypeChip(
                'Summary',
                AnswerType.summary,
                Icons.summarize,
                provider,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _buildTypeChip(
                'Explanation',
                AnswerType.explanation,
                Icons.lightbulb,
                provider,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(
      String label,
      AnswerType type,
      IconData icon,
      ShortAnswerProvider provider,
      ) {
    final isSelected = provider.selectedType == type;

    return GestureDetector(
      onTap: () => provider.setAnswerType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4361EE).withOpacity(0.15)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4361EE)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF4361EE)
                  : Colors.grey[600],
              size: 20,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF4361EE)
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedTermsSection(ShortAnswerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        const Text(
          'Related Terms',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212529),
          ),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.relatedTerms.map((term) {
            return GestureDetector(
              onTap: () {
                _queryController.text = term;
                provider.setQuery(term);
                provider.generateAnswer();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue[100]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  term,
                  style: const TextStyle(
                    color: Color(0xFF4361EE),
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showHistoryDialog() {
    final provider = Provider.of<ShortAnswerProvider>(context, listen: false);

    if (provider.recentQueries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No recent queries found'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Recent Queries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: provider.recentQueries.length,
                  itemBuilder: (context, index) {
                    final query = provider.recentQueries[index];

                    return ListTile(
                      leading: const Icon(Icons.history, size: 20),
                      title: Text(query),
                      onTap: () {
                        Navigator.pop(context);
                        _queryController.text = query;
                        provider.setQuery(query);
                        provider.generateAnswer();
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}