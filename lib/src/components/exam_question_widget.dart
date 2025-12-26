import 'package:flutter/material.dart';
import '../models/exam_model.dart';

class ExamQuestionWidget extends StatefulWidget {
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedIndex;
  final Function(int) onAnswerSelected;
  final bool showCodeSnippet;

  const ExamQuestionWidget({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    this.selectedIndex,
    required this.onAnswerSelected,
    this.showCodeSnippet = true, required bool showPoints, required String difficulty,
  }) : super(key: key);

  @override
  _ExamQuestionWidgetState createState() => _ExamQuestionWidgetState();
}

class _ExamQuestionWidgetState extends State<ExamQuestionWidget> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(ExamQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      setState(() {
        _selectedIndex = widget.selectedIndex;
      });
    }
  }

  void _handleAnswerSelection(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onAnswerSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${widget.questionNumber}/${widget.totalQuestions}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                Chip(
                  label: Text(
                    '${widget.question.points} points',
                    style: TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Question text
          Text(
            widget.question.question,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 16),

          // Code snippet (if available and showCodeSnippet is true)
          if (widget.question.codeSnippet != null && widget.showCodeSnippet)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Code Example:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      widget.question.codeSnippet!,
                      style: TextStyle(
                        fontFamily: 'Monospace',
                        color: Colors.green[300],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),

          // Answer options
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.question.options.length,
            itemBuilder: (context, index) {
              final option = widget.question.options[index];
              final isSelected = _selectedIndex == index;
              final isCorrectAnswer = index == widget.question.correctAnswerIndex;
              final showAsCorrect = isSelected && isCorrectAnswer;

              return GestureDetector(
                onTap: () => _handleAnswerSelection(index),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (showAsCorrect ? Colors.green[50] : Colors.red[50])
                        : Colors.grey[50],
                    border: Border.all(
                      color: isSelected
                          ? (showAsCorrect ? Colors.green : Colors.red)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Option letter
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (showAsCorrect ? Colors.green : Colors.red)
                              : Colors.grey[300]!,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      // Option text
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? (showAsCorrect ? Colors.green[900] : Colors.red[900])
                                : Colors.black,
                          ),
                        ),
                      ),

                      // Selection indicator
                      if (isSelected)
                        Icon(
                          showAsCorrect ? Icons.check_circle : Icons.cancel,
                          color: showAsCorrect ? Colors.green : Colors.red,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Explanation (show only if answer is selected)
          if (_selectedIndex != null && _selectedIndex != -1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explanation:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.question.explanation,
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          // Category and difficulty
          SizedBox(height: 20),
          Row(
            children: [
              Chip(
                label: Text(widget.question.category),
                backgroundColor: Colors.blue[100],
              ),
              SizedBox(width: 8),
              Chip(
                label: Text(
                  widget.question.type.toUpperCase(),
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: _getTypeColor(widget.question.type),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'quiz':
        return Colors.blue[100]!;
      case 'coding':
        return Colors.green[100]!;
      case 'exam':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}