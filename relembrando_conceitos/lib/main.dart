import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
     void ontap(int valor){
      print('Container $valor clicado');
    } 
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

        body: Center(
          child: ListView.builder(
            itemCount: 11,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => ontap(index),
                child: Container(
                  height: 300,
                  margin: EdgeInsets.all(5),
                  color: Colors.grey[300]!.withValues(alpha:0.5),
                  child: Center(
                    child: Text('Container numero $index'),
                  ),
                ),
              );
            },
            
          ),
        ),
      ),
    );
  }
}