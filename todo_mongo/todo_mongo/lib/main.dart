import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/pages/auth_page.dart';
import 'package:todo_mongo/services/mongo_service.dart';
import 'package:todo_mongo/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
      create: (context) => MongoService(),
      child: const MainApp(),
    ),);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: AuthPage(),
    );
  }
}
