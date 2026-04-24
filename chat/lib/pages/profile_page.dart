import 'package:chat/components/my_drawer.dart';
import 'package:chat/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final User? user = FirebaseAuth.instance.currentUser;
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Profile')),
      drawer: const MyDrawer(),
      body: FutureBuilder(
        future: _chatService.getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Usuário não encontrado no banco.'),
            );
          }

          final userData = snapshot.data!.data();

          if (userData == null) {
            return const Center(child: Text('Dados corrompidos.'));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: 64,
                  ),
                ),
                
                Text(
                  "${userData['username'] ?? 'Sem nome'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(" ${userData['email'] ?? 'Sem email'}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
