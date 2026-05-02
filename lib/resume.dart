import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'atsresult.dart';

class ResumeUploadPage extends StatefulWidget {
  const ResumeUploadPage({super.key});

  @override
  State<ResumeUploadPage> createState() => _ResumeUploadPageState();
}

class _ResumeUploadPageState extends State<ResumeUploadPage> {

  bool loading = false;

  Future<void> pickFile() async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (res == null) return;

    setState(() => loading = true);

    final file = res.files.first;

    final response = await ApiService.uploadResume(
      file.bytes!,
      file.name,
    );

    setState(() => loading = false);

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (_) => ATSPage(
          score: response['ats_score'],
          skills: response['skills'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Resume")),

      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: pickFile,
                child: const Text("Upload Resume"),
              ),
      ),
    );
  }
}