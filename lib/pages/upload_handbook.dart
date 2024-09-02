import 'package:cmp_handbook/pages/variables.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:toastification/toastification.dart';
import '../api/api_services.dart';
import 'dart:io';

class UploadHandbook extends StatefulWidget {
  const UploadHandbook({super.key});

  @override
  _UploadHandbookState createState() => _UploadHandbookState();
}

class _UploadHandbookState extends State<UploadHandbook> {
  File? selectedFile;
  bool isLoading = false;

  // Function to pick a file
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
        });
      } else {
        mounted ? ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected or invalid file.')),
        ): null;
      }
    } catch (e) {
      mounted ? ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      ): null;
    }
  }

  // Function to upload the selected file
  Future<void> uploadFile() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
      return;
    }

    setState(() {
      isLoading = true; // Start loading
    });

    final response = await apiService.uploadFile(selectedFile!);

    setState(() {
      isLoading = false; // Stop loading
    });

    if (response['success']) {
      _showToast("File uploaded successfully", ToastificationType.success);
    } else {
      _showToast("File upload Error", ToastificationType.error);
    }
  }

  void _showToast(String message, ToastificationType type) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      style: ToastificationStyle.fillColored,
      backgroundColor: colorGreen,
      primaryColor: colorGreen,
      type: type,
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                onPressed: ()=>Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios, color: colorGreen,)),
            Text('ADMIN - Upload Handbook', style: TextStyle(fontSize: 16, color: colorGreen),),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: pickFile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: colorGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Select file...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (selectedFile != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                    'Selected File: ${selectedFile!.path.split('/').last}'),
              ),
              ElevatedButton(
                onPressed: uploadFile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: colorGreen,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Upload File',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],

            if (isLoading) ...[
              const SizedBox(height: 20),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 child: LinearProgressIndicator(color: colorGreen,),
               ),
            ],
          ],
        ),
      ),
    );
  }
}
