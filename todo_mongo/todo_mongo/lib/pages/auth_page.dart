import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/pages/home_page.dart';
import 'package:todo_mongo/pages/login_or_register_page.dart';
import 'package:todo_mongo/services/mongo_service.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {

    final mongoService = Provider.of<MongoService>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<String?>(
        stream: mongoService.authStateChanges, 
        builder: (context, snapshot) {

          if (snapshot.hasData && snapshot.data != null) {
            return HomePage();
          }
          return const LoginOrRegisterPage();
        }
      ),
    );
  }
}