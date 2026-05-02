import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'interview.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool loading = false;

  int? atsScore;
  List skills = [];
  List questions = [];

  // ---------------- RESUME UPLOAD ----------------
  Future<void> uploadResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result == null) return;

    Uint8List fileBytes = result.files.first.bytes!;
    String fileName = result.files.first.name;

    setState(() {
      loading = true;
    });

    try {
      // 1. CALL BACKEND (ATS + SKILLS)
      final res = await ApiService.uploadResume(fileBytes, fileName);

      atsScore = res['ats_score'];
      skills = res['skills'];

      // 2. GET QUESTIONS FROM BACKEND
      final qRes = await ApiService.getQuestions(skills);

      questions = qRes['questions'];
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
    }

    setState(() {
      loading = false;
    });
  }

  // ---------------- START INTERVIEW ----------------
  void startInterview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InterviewPage(questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          'AI Interview Analyzer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // HEADER (UNCHANGED UI)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Smart Resume Intelligence System",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Upload resume → Get AI score → Generate interview questions",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // MAIN CARD (UNCHANGED UI BUT NOW FUNCTIONAL)
            Expanded(
              child: Center(
                child: InkWell(
                  onTap: uploadResume, // 🔥 CHANGED ONLY THIS
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Icon(
                          Icons.upload_file,
                          size: 70,
                          color: Colors.indigo,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Upload Your Resume",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Get ATS score + AI-generated interview questions based on your resume",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 20),

                        // ---------------- LOADING ----------------
                        if (loading)
                          const CircularProgressIndicator(),

                        // ---------------- ATS SCORE ----------------
                        if (atsScore != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            "ATS SCORE: $atsScore / 100",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],

                        // ---------------- START INTERVIEW ----------------
                        if (questions.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: startInterview,
                            child: const Text("Start Interview"),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}