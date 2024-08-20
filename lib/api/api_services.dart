import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../pages/variables.dart';
import 'dart:io';

class ApiService {
  final String baseUrl = 'http://192.168.43.38:3000';
  // final String baseUrl = 'http://192.168.1.145:3000';

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


  // Future<void> checkForUpdates() async {
  //   final url = Uri.parse('$baseUrl/handbook/info');
  //   try {
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final String lastUpdatedFromApi = data['last_updated'];
  //       final String? lastUpdatedFromStorage = await storage.read(key: "last_updated");
  //
  //       if (lastUpdatedFromStorage == null || lastUpdatedFromApi.compareTo(lastUpdatedFromStorage) > 0) {
  //         await downloadPdf();
  //         await storage.write(key: "last_updated", value: lastUpdatedFromApi);
  //       }
  //     } else {
  //       print("Failed to fetch last updated info from API");
  //     }
  //   } catch (error) {
  //     print("Error checking for updates: $error");
  //   }
  // }

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


  Future logout() async {
    await storage.deleteAll();
  }

}

ApiService apiService = new ApiService();