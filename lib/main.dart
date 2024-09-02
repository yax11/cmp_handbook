import 'package:cmp_handbook/pages/add_student.dart';
import 'package:cmp_handbook/pages/admin_dashboard.dart';
import 'package:cmp_handbook/pages/manage_complaints.dart';
import 'package:cmp_handbook/pages/upload_handbook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import './pages/variables.dart';
import 'package:cmp_handbook/pages/complaints.dart';
import 'package:cmp_handbook/pages/home.dart';
import 'package:cmp_handbook/pages/login.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final bool isSessionSet = await userSessionSet();

  await Future.delayed(const Duration(seconds: 5));

  FlutterNativeSplash.remove();

  runApp(MyApp(isSessionSet: isSessionSet));
}

Future<bool> userSessionSet() async {
  String? session = await storage.read(key: "user_data");
  return session != null && session.isNotEmpty;
}

class MyApp extends StatelessWidget {
  final bool isSessionSet;
  const MyApp({super.key, required this.isSessionSet});

  @override
  Widget build(BuildContext context) {
    // Set the initial route based on the session state
    String initialRoute = isSessionSet ? "/" : "auth";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CMP HandBook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      onGenerateRoute: MainRouter.generateRoute,
      initialRoute: initialRoute,
    );
  }
}

class MainRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "":
        return MaterialPageRoute(builder: (context) => const HomePage());
      case "/":
        return MaterialPageRoute(builder: (context) => const HomePage());
      case "auth":
        return MaterialPageRoute(builder: (context) => const Login());
      case "home":
        return MaterialPageRoute(builder: (context) => const HomePage());
      case "complaints":
        return MaterialPageRoute(builder: (context) => const Complaints());
      case "adminDashboard":
        return MaterialPageRoute(builder: (context) => const AdminDashboard());
      case "uploadHandbook":
        return MaterialPageRoute(builder: (context) => const UploadHandbook());
      case "addStudent":
        return MaterialPageRoute(builder: (context) => const AddStudent());
      case "manageComplaints":
        return MaterialPageRoute(builder: (context) => const ViewComplaints());
      default:
        return MaterialPageRoute(builder: (context) => const HomePage());
    }
  }
}
