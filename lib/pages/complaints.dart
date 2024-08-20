import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toastification/toastification.dart';
import '../api/api_services.dart';
import '../pages/variables.dart';

class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  final storage = FlutterSecureStorage();
  final TextEditingController _complaintController = TextEditingController();
  String _fullName = '';
  String _userId = '';
  ApiService apiService = ApiService();
  bool _isLoading = false; // Added for loading state

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await storage.read(key: 'user_data');
    if (userData != null) {
      final data = jsonDecode(userData);
      setState(() {
        _fullName = data['full_name'] ?? 'User';
        _userId = data['reg'] ?? ''; // Assuming 'reg' is the key for userId
      });
    }
  }

  Future<void> _sendComplaint() async {
    final complaintText = _complaintController.text.trim();
    if (complaintText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Complaint cannot be empty")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final response = await apiService.sendComplaint(complaintText, _userId);
      if (response['status'] == true && mounted) {
        toastification.show(
            context: context,
            title: const Text('Complaint successfully send'),
            autoCloseDuration: const Duration(seconds: 5),
            style: ToastificationStyle.fillColored,
            backgroundColor: colorGreen,
            primaryColor: colorGreen,
            type: ToastificationType.success,
            applyBlurEffect: false,
            alignment: Alignment.bottomCenter
        );
        setState(() {
          _complaintController.clear();
          _complaintController.text = "";

        });
        Navigator.pop(context);
      } else {
        toastification.show(
            context: context,
            title: Text(response['message'] ?? "Failed to send complaint"),
            autoCloseDuration: const Duration(seconds: 5),
            style: ToastificationStyle.fillColored,
            backgroundColor: colorGreen,
            primaryColor: colorGreen,
            type: ToastificationType.error,
            applyBlurEffect: false,
            alignment: Alignment.bottomCenter
        );
      }
    } catch (e) {
      toastification.show(
          context: context,
          title: Text("An error occurred while sending complaint"),
          autoCloseDuration: const Duration(seconds: 5),
          style: ToastificationStyle.fillColored,
          backgroundColor: colorGreen,
          primaryColor: colorGreen,
          type: ToastificationType.error,
          applyBlurEffect: false,
          alignment: Alignment.bottomCenter
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  void dispose() {
    _complaintController.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorGreen,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            Text("Log Complaints", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _complaintController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top, // Start text from the top
                decoration: InputDecoration(
                  hintText: 'Enter your complaint here...',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorGreen, width: 1.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorGreen, width: 2.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendComplaint, // Disable button when loading
              style: ElevatedButton.styleFrom(
                backgroundColor: colorGreen,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Text(
                "SEND",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
