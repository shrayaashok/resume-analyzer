import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {

  static const baseUrl = "https://resume-analyzer-ml-backend.onrender.com";


  // ---------------- RESUME ----------------
  static Future<Map> uploadResume(Uint8List file, String name) async {

    var req = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/analyze-resume"),
    );

    req.files.add(http.MultipartFile.fromBytes(
      "file",
      file,
      filename: name,
    ));

    var res = await req.send();
    var data = await res.stream.bytesToString();

    return jsonDecode(data);
  }


  // ---------------- QUESTIONS ----------------
  static Future<Map> getQuestions(List skills) async {
    final res = await http.post(
      Uri.parse("$baseUrl/questions"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"skills": skills}),
    );

    return jsonDecode(res.body);
  }


  // ---------------- ANSWER EVALUATION ----------------
  static Future<Map> evaluate(String q, String a) async {
    final res = await http.post(
      Uri.parse("$baseUrl/evaluate"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "question": q,
        "answer": a
      }),
    );

    return jsonDecode(res.body);
  }
}
