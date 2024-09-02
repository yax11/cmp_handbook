import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../pages/variables.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // final String baseUrl = 'http://192.168.43.38:3000';//phone
  // final String baseUrl = 'http://192.168.0.145:3000';//Mifi

  final String baseUrl = 'https://cmp-handbook-backend.onrender.com';

  Future<Map<String, dynamic>> attemptLogin(String reg, String phone) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reg': reg, 'phone': phone}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Login failed. Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error during login attempt: $e');
      return {
        'success': false,
        'message': 'An error occurred during login',
        'error': e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> sendComplaint(String complaintText, String userId) async {
    final url = Uri.parse('$baseUrl/sendComplaint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'complaintText': complaintText,
          'userId': userId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Complaint submission failed. Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error during complaint submission: $e');
      return {
        'success': false,
        'message': 'An error occurred during complaint submission',
        'error': e.toString()
      };
    }
  }

  Future<String> downloadPdf() async {
    final url = Uri.parse('$baseUrl/handbook/download');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/handbook.pdf');
        await file.writeAsBytes(response.bodyBytes, flush: true);
        // print("PDF downloaded and saved successfully");
        return "1";
      } else {
        return "Failed to download PDF";
      }
    } catch (error) {
      return "Error downloading PDF: $error";
    }
  }


  Future<Map<String, dynamic>> uploadFile(File file) async {
    final url = Uri.parse('$baseUrl/uploadHandbook');
    final mimeType = lookupMimeType(file.path);

    try {
      final request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(mimeType ?? 'application/octet-stream'),
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return jsonDecode(responseData);
      } else {
        return {
          'success': false,
          'message': 'File upload failed. Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error during file upload: $e');
      return {
        'success': false,
        'message': 'An error occurred during file upload',
        'error': e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> addStudent(String fullName, String phone, String reg) async {
    final url = Uri.parse('$baseUrl/add-student');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'phone': phone,
        'reg': reg,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add student. Error: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchComplaints() async {
    final url = Uri.parse('$baseUrl/complaints');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load complaints. Error: ${response.body}');
    }
  }

  Future logout() async {
    await storage.deleteAll();
  }

}

ApiService apiService = ApiService();