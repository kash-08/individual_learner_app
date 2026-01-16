// ai_response_card.dart - Fixed version

import 'package:flutter/material.dart';

class AIResponseCard extends StatelessWidget {
  final String response;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;

  const AIResponseCard({
    super.key,
    required this.response,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.onCopy,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Response',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212529),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onCopy,
                      icon: const Icon(Icons.content_copy, size: 20),
                      tooltip: 'Copy Response',
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onRegenerate,
                      icon: const Icon(Icons.refresh, size: 20),
                      tooltip: 'Regenerate',
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Content Area
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 100,
                  maxHeight: double.infinity,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
            ),
            SizedBox(height: 16),
            Text(
              'Generating response...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (hasError) {
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRegenerate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      );
    }

    if (response.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.grey[300],
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter a query above and click "Generate AI Response"',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    // This is the key fix - properly constrained text with max width
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      child: Container(
        width: double.infinity, // Important for text wrapping
        child: Text(
          response,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Color(0xFF495057),
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}