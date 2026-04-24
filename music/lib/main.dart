import 'package:flutter/material.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:music/pages/home_page.dart';
import 'package:music/pages/player_page.dart';
import 'package:music/pages/playlist_page.dart';
import 'package:music/themes/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PlaylistProvider(),
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
      theme: lightMode,
      darkTheme: darkMode,
      home: HomePage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/playlist') {
          final String argument = settings.arguments as String;

          return MaterialPageRoute(builder: (context) {
              return PlaylistPage(playlistName: argument);
            },
          );
        }
        if (settings.name == '/player') {
          return MaterialPageRoute(builder: (context) {
              return PlayerPage();
            },
          );
        }
        return MaterialPageRoute(builder: (context) {
              return HomePage();
            },);
      },
    );
  }
}
