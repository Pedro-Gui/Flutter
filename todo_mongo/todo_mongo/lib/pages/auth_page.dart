import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/pages/create_edit_task.dart';
import 'package:todo_mongo/pages/home_page.dart';
import 'package:todo_mongo/pages/login_or_register_page.dart';
import 'package:todo_mongo/pages/profile_page.dart';
import 'package:todo_mongo/services/mongo_service.dart';

class AuthPage extends StatelessWidget {
  final String page;
  final Map<String, dynamic>? args;
  const AuthPage({super.key, this.page = '/homePage', this.args});

  @override
  Widget build(BuildContext context) {

    final mongoService = Provider.of<MongoService>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<String?>(
        stream: mongoService.authStateChanges, 
        builder: (context, snapshot) {

          if (!snapshot.hasData && snapshot.data == null) {
            return const LoginOrRegisterPage();
          }

          switch (page) {
            case '/loginOrRegisterPage':
              return const LoginOrRegisterPage();
            case '/homePage':
              return const HomePage();
            case '/profilePage':
              return const ProfilePage();
            case '/createOrEditPage':
              return CreateEditTask(
                isEdit: args?['isEdit'] ?? false, 
                task: args?['task'], 
              );
            default:
              return const LoginOrRegisterPage();
          }
        }
      ),
    );
  }
}