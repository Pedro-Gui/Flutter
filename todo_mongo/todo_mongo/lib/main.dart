import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_mongo/pages/create_edit_task.dart';
import 'package:todo_mongo/pages/home_page.dart';
import 'package:todo_mongo/services/auth/login_or_register.dart';
import 'package:todo_mongo/pages/profile_page.dart';
import 'package:todo_mongo/services/auth/auth_gate.dart';
import 'package:todo_mongo/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp( const ProviderScope(child: MainApp(),)    );
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
