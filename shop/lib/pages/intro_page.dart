import 'package:flutter/material.dart';
import 'package:shop/pages/config/colors.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SysColors.backgroundColor,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
                child: Image.asset(  
                  'lib/images/logo.png',
                  width: 250,
                  height: 250,
                ),
              ),
          
              Text(
                'Dragon Ball Store',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
          
              const SizedBox(height: 20),
          
              Text(
                'Bem-vindo à loja oficial de produtos do Dragon Ball!',
                style: TextStyle(
                  fontSize: 16,
                  color: SysColors.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/homePage'),
                child: Container(
                  decoration: BoxDecoration(
                    color: SysColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                
                  padding:  EdgeInsets.all(25),
                
                  child: Center(
                    child: Text(
                      'Shop Now',
                      style: TextStyle(
                        color: SysColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),)
                    ),
                ),
              )

            ]
          ),
        ),
      )
    );
  }
}