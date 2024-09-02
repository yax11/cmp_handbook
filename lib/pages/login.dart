import 'dart:convert';

import 'package:flutter/material.dart';
import './../api/api_services.dart';
import './variables.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final TextEditingController _regController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String _errorMessage = '';

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final reg = _regController.text.trim();
    final phone = _phoneController.text.trim();

    if (reg.isEmpty || phone.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please fill in both fields';
      });
      return;
    }

    final result = await _apiService.attemptLogin(reg, phone);

    setState(() {
      _isLoading = false;
    });
    if (result['success']) {
      if (reg == 'admin') {
        await storage.write(key: 'user_data', value: jsonEncode(result['data']));
        if (mounted) {
          Navigator.pushNamed(context, 'adminDashboard');
        }
      } else {
        await storage.write(key: 'user_data', value: jsonEncode(result['data']));
        if (mounted) {
          Navigator.pushNamed(context, 'home');
        }
      }
    } else {
      setState(() {
        _errorMessage = result['message'] + (result['error'] ?? "");
      });
    }
  }

  checkStatus() async {
    final bool isSessionSet = await userSessionSet();
    if (isSessionSet) {
      mounted ? Navigator.pushNamed(context, "home") : null;
    }
  }

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: const DecorationImage(
                  image: AssetImage('assets/nsuk2.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  opacity: 0.05
              ),
              color: Colors.black.withOpacity(0.1),
            ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    color: colorGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,

                  ),
                ),
                Text(
                  "Login to your account",
                  style: TextStyle(
                    color: colorGreen.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Image.asset(
                    'assets/book.png',
                    height: 120,
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: _regController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colorGreen),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colorGreen),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colorGreen),
                        ),
                        hintText: "Enter Reg. Number",
                        hintStyle: TextStyle(color: colorGreen.withOpacity(0.5)),
                      ),
                      style: TextStyle(color: colorGreen),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _phoneController,
                      // keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colorGreen),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colorGreen),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colorGreen),
                        ),
                        hintText: "Enter Phone Number",
                        hintStyle: TextStyle(color: colorGreen.withOpacity(0.5)),
                      ),
                      style: TextStyle(color: colorGreen),
                    ),
                    const SizedBox(height: 30),
                    if (_errorMessage.isNotEmpty) ...[
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                    ],
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: colorGreen
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

