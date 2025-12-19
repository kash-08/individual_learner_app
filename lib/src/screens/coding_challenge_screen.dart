import 'package:flutter/material.dart';
import '../models/exam_model.dart';

class CodingChallengeScreen extends StatefulWidget {
  final CodingChallenge challenge;
  final String initialCode;

  const CodingChallengeScreen({
    Key? key,
    required this.challenge,
    this.initialCode = '',
  }) : super(key: key);

  @override
  _CodingChallengeScreenState createState() => _CodingChallengeScreenState();
}

class _CodingChallengeScreenState extends State<CodingChallengeScreen> {
  late TextEditingController _codeController;
  String _output = '';
  bool _isRunning = false;
  bool _showLineNumbers = true;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
      text: widget.initialCode.isNotEmpty
          ? widget.initialCode
          : widget.challenge.starterCode,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _output = 'Running code...';
    });

    // Simulate code execution
    await Future.delayed(Duration(seconds: 2));

    // Mock test execution
    int passedTests = 0;
    List<String> testResults = [];

    for (var testCase in widget.challenge.testCases) {
      if (!testCase.isHidden) {
        // Mock test execution - in real app, this would run actual code
        bool passed = _mockTestExecution(_codeController.text, testCase);
        if (passed) passedTests++;
        testResults.add('${testCase.input} → ${passed ? '✅' : '❌'} Expected: ${testCase.expectedOutput}');
      }
    }

    final totalVisibleTests = widget.challenge.testCases.where((tc) => !tc.isHidden).length;
    final score = (passedTests / totalVisibleTests * 100).toInt();

    setState(() {
      _isRunning = false;
      _output = '''
✅ Code executed successfully!
--------------------
Challenge: ${widget.challenge.title}
Language: ${widget.challenge.language}
Difficulty: ${widget.challenge.difficulty}
--------------------
Test Results:
${testResults.join('\n')}
--------------------
Passed: $passedTests/$totalVisibleTests
Score: $score%
${score >= 80 ? '🎉 Challenge Passed!' : '⚠️ Keep trying!'}
      ''';
    });
  }

  bool _mockTestExecution(String code, TestCase testCase) {
    // Simple mock execution
    // In real app, this would execute code in a sandbox
    if (widget.challenge.language == 'javascript') {
      if (widget.challenge.title.contains('Reverse')) {
        return code.contains('reverse') || code.contains('split') || code.contains('join');
      } else if (widget.challenge.title.contains('Parentheses')) {
        return code.contains('stack') || code.contains('map') || code.contains('pop');
      }
    } else if (widget.challenge.language == 'python') {
      if (widget.challenge.title.contains('Fibonacci')) {
        return code.contains('fibonacci') || code.contains('recursion');
      }
    }
    return code.trim().isNotEmpty; // Default: pass if code is not empty
  }

  void _showHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text('Hint'),
          ],
        ),
        content: Text(
            'For ${widget.challenge.title}, think about the algorithm approach. '
                'Try to break down the problem into smaller steps.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showSolution() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.code, color: Colors.blue),
            SizedBox(width: 8),
            Text('Solution'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              widget.challenge.solution,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                backgroundColor: Colors.grey.shade100,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeView(String code, {bool readOnly = false}) {
    final lines = code.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showLineNumbers)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  lines.length,
                      (index) => Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: readOnly
                ? SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SelectableText(
                  code,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                : TextField(
              controller: _codeController,
              maxLines: null,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challenge.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showLineNumbers = !_showLineNumbers;
              });
            },
            icon: Icon(_showLineNumbers ? Icons.list : Icons.list_alt),
            tooltip: 'Toggle Line Numbers',
          ),
          IconButton(
            onPressed: _showHint,
            icon: Icon(Icons.lightbulb_outline),
            tooltip: 'Show Hint',
          ),
          IconButton(
            onPressed: _showSolution,
            icon: Icon(Icons.code),
            tooltip: 'Show Solution',
          ),
        ],
      ),
      body: Column(
        children: [
          // Problem statement
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Problem Statement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  widget.challenge.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(widget.challenge.difficulty),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.speed, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            widget.challenge.difficulty,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.code, size: 16, color: Colors.amber.shade800),
                          SizedBox(width: 4),
                          Text(
                            widget.challenge.language,
                            style: TextStyle(
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.green.shade800),
                          SizedBox(width: 4),
                          Text(
                            '${widget.challenge.points} points',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Time Limit: ${widget.challenge.timeLimit} minutes',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Code editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Code Editor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Line ${_codeController.text.split('\n').length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: _buildCodeView(_codeController.text),
                  ),
                ],
              ),
            ),
          ),

          // Output section
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(top: BorderSide(color: Colors.grey.shade700)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.terminal, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Output',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    if (_output.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Execution Complete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _output,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Controls
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runCode,
                    icon: _isRunning
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : Icon(Icons.play_arrow),
                    label: Text(_isRunning ? 'Running...' : 'Run Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _codeController.clear();
                      setState(() {
                        _output = '';
                      });
                    },
                    icon: Icon(Icons.clear_all),
                    label: Text('Clear'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _codeController.text = widget.challenge.starterCode;
                      setState(() {
                        _output = '';
                      });
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Reset'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}