import 'package:flutter/material.dart';
import 'interviewloading.dart';

class ATSPage extends StatelessWidget {
  final int score;
  final List skills;

  const ATSPage({
    super.key,
    required this.score,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 80),

            Text(
              "ATS SCORE",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),

            Text(
              "$score / 100",
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              children: skills
                  .map((e) => Chip(label: Text(e.toString())))
                  .toList(),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        InterviewLoadingPage(skills: skills),
                  ),
                );
              },
              child: const Text("Start Interview"),
            ),
          ],
        ),
      ),
    );
  }
}