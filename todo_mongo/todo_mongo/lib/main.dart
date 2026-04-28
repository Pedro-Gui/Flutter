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
      home: const AuthPage(),
      initialRoute: '/loginOrRegisterPage',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/loginOrRegisterPage':
          case '/homePage':
            return MaterialPageRoute(
              builder: (context) => const AuthPage(),
            );
          case '/profilePage':
            return MaterialPageRoute(
              builder: (context) => const AuthPage(page: '/profilePage'),
            );
          case '/createOrEditPage':
            final args = (settings.arguments as Map<String, dynamic>?) ?? {};
            return MaterialPageRoute(
              builder: (context) => AuthPage(page: '/createOrEditPage', args: args),
            );
          default:
            return MaterialPageRoute(builder: (context) => const AuthPage(page: '/loginOrRegisterPage'));
        }}
    );
  }
}
