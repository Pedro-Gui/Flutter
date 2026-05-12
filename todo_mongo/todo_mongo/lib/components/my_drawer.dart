import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_mongo/services/auth/auth_controller.dart';
import 'package:todo_mongo/models/user_model.dart';
import 'package:todo_mongo/services/task/task_controller.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authControllerProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                switch (authService) {
                  AsyncData(:final value) => _buildHeader(context, value),
                  AsyncError() => const DrawerHeader(
                    child: Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                  _ => const DrawerHeader(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                },
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: const Text('Home'),
                    leading: const Icon(Icons.home),
                    onTap: () {
                      context.pop(context);
                      context.go('/home');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: const Text('Profile'),
                    leading: const Icon(Icons.person),
                    onTap: () {
                      context.pop(context);
                      context.go('/profile');
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 25, bottom: 25),
              child: ListTile(
                title: const Text('logout'),
                leading: const Icon(Icons.logout),
                onTap: () {
                  context.pop(context);
                  ref.invalidate(taskControllerProvider);
                  ref.invalidate(tasksStreamProvider);
                  ref.read(authControllerProvider.notifier).signOut();
                  
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    final profile = user?.profile ?? {};
    final base64String = profile['imagem'] ?? '';

    return DrawerHeader(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            backgroundImage: (base64String != null && base64String.isNotEmpty)
                ? MemoryImage(base64Decode(base64String))
                : null,
            child: (base64String == null || base64String.isEmpty)
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            user?.username ?? 'undefined name',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
