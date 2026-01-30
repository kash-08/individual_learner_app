import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../models/exam_model.dart';
import 'result_details_screen.dart';

class ResultDetailsWrapper extends StatelessWidget {
  final QuizResult result;

  const ResultDetailsWrapper({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Pass existing providers from parent context
        Provider<UserProvider>.value(value: Provider.of<UserProvider>(context, listen: false)),
        Provider<AuthProvider>.value(value: Provider.of<AuthProvider>(context, listen: false)),
      ],
      child: ResultDetailsScreen(result: result, userName: '', userEmail: '',),
    );
  }
}