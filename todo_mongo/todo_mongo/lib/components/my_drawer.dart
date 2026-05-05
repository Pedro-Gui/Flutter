import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/services/auth_service.dart';
import 'package:todo_mongo/services/task_service.dart';
import 'package:todo_mongo/services/user_model.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                StreamBuilder(
                  stream: authService.currentUserData,
                  builder: (context, snapshot) {
                    if (authService.currentUserId == null) {
                      return const Center(
                        child: Text('Faça login para ver seu perfil.'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('Faça login para ver seu perfil.'),
                      );
                    }

                    final User user = snapshot.data!;
                    final profile = user.profile ?? {};
                    final base64String = profile['imagem'] ?? '';

                    return DrawerHeader(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.inversePrimary,
                            backgroundImage:
                                (base64String != null &&
                                    base64String.isNotEmpty)
                                ? MemoryImage(base64Decode(base64String))
                                : null,
                            child:
                                (base64String == null || base64String.isEmpty)
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: const Text('Home'),
                    leading: const Icon(Icons.home),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/homePage');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: const Text('Profile'),
                    leading: const Icon(Icons.person),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profilePage');
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
                  Navigator.pop(context);
                  context.read<TaskService>().clearSubscription();
                  authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
