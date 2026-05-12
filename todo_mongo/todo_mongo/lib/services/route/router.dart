import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:todo_mongo/models/task_model.dart';
import 'package:todo_mongo/models/user_model.dart';
import 'package:todo_mongo/pages/create_edit_task.dart';
import 'package:todo_mongo/pages/home_page.dart';
import 'package:todo_mongo/pages/login_page.dart';
import 'package:todo_mongo/pages/register_page.dart';
import 'package:todo_mongo/pages/profile_page.dart';
import 'package:todo_mongo/services/auth/auth_controller.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final authStateNotifier = ValueNotifier<bool>(false);

  ref.listen<AsyncValue<User?>>(authControllerProvider, (_, next) {
    authStateNotifier.value = next.value != null;
  });

  ref.onDispose(() {
    authStateNotifier.dispose();
  });

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authStateNotifier,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/task-detail',
        name: 'taskDetail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CreateEditTask(
            isEdit: extra['isEdit'] as bool? ?? false,
            task: extra['task'] as Task?,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      //if (authState.isLoading) return null;

      final bool loggedIn = authState.value != null;
      final bool isAuthRoute =
          state.uri.path == '/login' ||
          state.uri.path == '/register';

      
      if (!loggedIn && !isAuthRoute) {
        return '/login';
      }

      if (loggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
  );
}
