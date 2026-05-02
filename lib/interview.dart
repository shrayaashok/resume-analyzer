import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'api_service.dart';

class InterviewPage extends StatefulWidget {
  final List questions;

  const InterviewPage({super.key, required this.questions});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {

  int index = 0;
  String answer = "";
  bool loading = false;

  late stt.SpeechToText speech;
  bool isListening = false;

  List<int> scores = [];

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  // 🎤 START SPEECH
  void startListening() async {
    bool available = await speech.initialize();

    if (available) {
      setState(() => isListening = true);

      speech.listen(
        onResult: (result) {
          setState(() {
            answer = result.recognizedWords;
          });
        },
      );
    }
  }

  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  // 🧠 SEND TO AI BACKEND
  void submitAnswer() async {

    setState(() => loading = true);

    final res = await ApiService.evaluate(
      widget.questions[index],
      answer,
    );

    scores.add(res['score']);

    setState(() {
      loading = false;
      answer = "";
    });

    if (index < widget.questions.length - 1) {
      setState(() => index++);
    } else {
      showResult();
    }
  }

  // 📊 FINAL SCORE
  void showResult() {
    int total = scores.reduce((a, b) => a + b);
    int finalScore = (total / scores.length).round();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Interview Completed"),
        content: Text("Final Score: $finalScore / 100"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text("AI Voice Interview")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // QUESTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.questions[index],
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            // ANSWER DISPLAY
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(answer.isEmpty ? "Speak your answer..." : answer),
            ),

            const SizedBox(height: 20),

            // 🎤 MIC BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton.icon(
                  onPressed: isListening ? stopListening : startListening,
                  icon: Icon(isListening ? Icons.mic_off : Icons.mic),
                  label: Text(isListening ? "Stop" : "Speak"),
                ),

                const SizedBox(width: 20),

                ElevatedButton(
                  onPressed: loading ? null : submitAnswer,
                  child: const Text("Submit"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text("Question ${index + 1} / ${widget.questions.length}"),
          ],
        ),
      ),
    );
  }
}