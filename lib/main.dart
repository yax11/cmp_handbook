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

  // Remove the splash screen after initialization
  FlutterNativeSplash.remove();

  runApp(MyApp(isSessionSet: isSessionSet));
}

Future<bool> userSessionSet() async {
  String? session = await storage.read(key: "userID");
  return session != null && session.isNotEmpty;
}

class MyApp extends StatelessWidget {
  final bool isSessionSet;
  const MyApp({super.key, required this.isSessionSet});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CMP HandBook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: MainRouter.generateRoute,
      initialRoute: isSessionSet ? "home" : "auth",
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
      default:
        return MaterialPageRoute(builder: (context) => const HomePage());
    }
  }
}