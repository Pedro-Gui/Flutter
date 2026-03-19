import 'package:flutter/material.dart';
import 'package:curso1/pages/home.dart';
import 'package:curso1/pages/profile.dart';
import 'package:curso1/pages/settings.dart';

void main() {
  runApp( MyApp());
}
class MyApp extends StatefulWidget {
   MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final bool isDarkMode = false;

  int pageIndex = 0;

  final List pages = [
    HomePage(),
    Profile(),
    Settings(),
  ];

  void onPageChanged(int index){
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.lightGreenAccent,

        appBar: AppBar(
        title: Text('Aprendendo Flutter'),
        backgroundColor:Colors.lightGreenAccent,
        elevation: 1,
        leading: Icon(Icons.menu),
        actions: [
          Icon(Icons.search),
          SizedBox(width: 10),
          Icon(Icons.more_vert),
          SizedBox(width: 10),
          Icon(Icons.logout),
          SizedBox(width: 10),
        ],
      ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.lightGreenAccent,
          elevation: 1,
          currentIndex: pageIndex,
          selectedItemColor: Colors.black,
          onTap: onPageChanged,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home), 
              label: 'Home'
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person), 
              label: 'Profile'
              ),
              BottomNavigationBarItem(
              icon: Icon(Icons.settings), 
              label: 'Settings'
              ),
          ]
        ),
        body: pages[pageIndex],
      ),
    );
  }
}