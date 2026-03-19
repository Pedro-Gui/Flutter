import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
     void ontap(int valor){
      print('Container $valor clicado');
    } 

    return Scaffold(
        backgroundColor: Colors.lightGreenAccent,
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
                    child: Text('$index'),
                  ),
                ),
              );
            },
            
          ),
        ),
    );
  }
}