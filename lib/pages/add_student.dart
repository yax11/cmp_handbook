import 'package:cmp_handbook/pages/variables.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../api/api_services.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  _AddStudentState createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  ApiService apiServices = ApiService();
  final TextEditingController _regController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _showToast(String message, ToastificationType type) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      style: ToastificationStyle.fillColored,
      // backgroundColor: colorGreen,
      // primaryColor: colorGreen,
      type: type,
      alignment: Alignment.bottomCenter,
    );
  }

  void _submitForm() async {
    String fullName = _nameController.text;
    String phone = _phoneController.text;
    String reg = _regController.text;

    if (fullName.isEmpty || phone.isEmpty || reg.isEmpty) {
      _showToast('Please fill in all fields', ToastificationType.error);
      return;
    }

    try {
      final response = await apiServices.addStudent(fullName, phone, reg);
      _showToast(response['message'], ToastificationType.success);
      mounted?Navigator.pop(context):null;
    } catch (e) {
      _showToast(e.toString(), ToastificationType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back_ios, color: colorGreen),
            ),
            Text(
              'ADMIN - Add student',
              style: TextStyle(fontSize: 16, color: colorGreen),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _regController,
                decoration: const InputDecoration(
                  labelText: 'Reg. Number',
                  hintText: 'Enter Reg. Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: colorGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Send",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
