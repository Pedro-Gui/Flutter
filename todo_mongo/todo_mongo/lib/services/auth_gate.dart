import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/pages/home_page.dart';
import 'package:todo_mongo/services/auth_service.dart';
import 'package:todo_mongo/services/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<String?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoginOrRegisterPage();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }
        
        return const LoginOrRegisterPage();
      },
    );
  }
}