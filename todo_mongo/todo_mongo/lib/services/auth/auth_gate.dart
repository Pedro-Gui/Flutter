import 'package:flutter/material.dart';
import 'package:todo_mongo/pages/home_page.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_mongo/services/auth/login_or_register.dart';
import 'auth_controller.dart';


class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return switch (authState) {
      AsyncData(:final value) => value == null 
          ? const LoginOrRegisterPage() 
          : const HomePage(),
      
      AsyncError() => const LoginOrRegisterPage() ,
      
      _ => const LoginOrRegisterPage() 
    };
  }
}