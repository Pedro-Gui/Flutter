import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/pages/create_edit_task.dart';
import 'package:todo_mongo/pages/home_page.dart';
import 'package:todo_mongo/services/login_or_register.dart';
import 'package:todo_mongo/pages/profile_page.dart';
import 'package:todo_mongo/services/auth_gate.dart';
import 'package:todo_mongo/services/mongo_service.dart';
import 'package:todo_mongo/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => MongoService(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/homePage':
            return MaterialPageRoute(builder: (context) => const HomePage());
          case '/profilePage':
            return MaterialPageRoute(builder: (context) => const ProfilePage());
          case '/createOrEditPage':
            final args = (settings.arguments as Map<String, dynamic>?) ?? {};
            return MaterialPageRoute(
              builder: (context) => CreateEditTask(
                isEdit: args['isEdit'] ?? false,
                task: args['task'],
              ),
            );
          case '/loginOrRegisterPage':
            return MaterialPageRoute(builder: (context) => const LoginOrRegisterPage(),);
          default:
            return MaterialPageRoute(builder: (context) => const AuthGate());
        }
      },
    );
  }
}
