import 'package:ecommerce/config/routes.dart';
import 'package:ecommerce/pages/intro_page.dart';
import 'package:ecommerce/config/theme.dart';
import 'package:ecommerce/pages/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Shop(), 
      child: const MyApp()
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: IntroPage(),
      routes: Routes.routes.map(
        (key, value) => MapEntry(key, (context) => value),
      ),
    );
  }
}
