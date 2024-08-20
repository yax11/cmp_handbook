
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

final storage = FlutterSecureStorage();

 Color colorGreen = const Color(0xff138C01);


Future<String?> getUserSession() async {
 return await storage.read(key: "userID");
}

Future<bool> userSessionSet() async {
 String? session = await getUserSession();
 return session != null && session.isNotEmpty;
}

