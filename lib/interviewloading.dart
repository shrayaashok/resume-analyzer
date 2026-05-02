import 'package:flutter/material.dart';
import 'api_service.dart';
import 'interview.dart';

class InterviewLoadingPage extends StatefulWidget {
  final List skills;

  const InterviewLoadingPage({super.key, required this.skills});

  @override
  State<InterviewLoadingPage> createState() => _InterviewLoadingPageState();
}

class _InterviewLoadingPageState extends State<InterviewLoadingPage> {

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final res = await ApiService.getQuestions(widget.skills);

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (_) => InterviewPage(
          questions: res['questions'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}