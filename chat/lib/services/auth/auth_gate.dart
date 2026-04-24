import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/settings_page.dart';
import 'package:chat/pages/social_page.dart';
import 'package:chat/services/auth/login_or_register.dart';
import 'package:chat/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  final int page;
  final String? receiverUsername;
  final String? receiverID;
  const AuthGate({
    super.key,
    required this.page,
    this.receiverUsername,
    this.receiverID,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoginOrRegister();
          switch (page) {
            case 0:
              return HomePage();
            case 1:
              return const SettingsPage();
            case 2:
              return SocialPage();
            case 3:
              return (receiverUsername != null && receiverID != null)
                  ? ChatPage(
                      receiverUsername: receiverUsername!,
                      receiverID: receiverID!,
                    )
                  : HomePage();
            case 4:
              return ProfilePage();
            default:
              return HomePage();
          }
        },
      ),
    );
  }
}
