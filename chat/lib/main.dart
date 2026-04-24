import 'package:chat/services/auth/auth_gate.dart';
import 'package:chat/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(page: 0,),
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: '/loginOrRegisterPage',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/loginOrRegisterPage':
          case '/homePage':
            return MaterialPageRoute(
              builder: (context) => const AuthGate(page: 0,),
            );
          case '/settingsPage':
            return MaterialPageRoute(
              builder: (context) => const AuthGate(page: 1),
            );
          case '/chatPage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AuthGate(page: 3, receiverUsername: args['username'], receiverID: args['id']),
            );
          case '/socialPage':
            return MaterialPageRoute(
              builder: (context) => const AuthGate(page: 2),
            );
          case '/profilePage':
            return MaterialPageRoute(
              builder: (context) => const AuthGate(page: 4),
            );
          default:
            return MaterialPageRoute(builder: (context) => const AuthGate(page: 0));
        }
      },
    );
  }
}
