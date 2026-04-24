import 'package:chat/services/auth/auth_service.dart';
import 'package:chat/components/my_button.dart';
import 'package:chat/components/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final  TextEditingController passwordController = TextEditingController();
  final void Function()? onTap;
  LoginPage({super.key, required this.onTap});
  
  void onLogin(BuildContext context) async{
    try{
         await AuthService().signInWithEmailAndPassword(usernameController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    usernameController.text = 'test@gmail.com';
    passwordController.text = 'password';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/images/wolf.png', height: 200, width: 200),
            
                SizedBox(height: 15),
            
                Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
            
                SizedBox(height: 25),
            
                MyTextfield(controller: usernameController, hintText: 'Username', obscureText: false),
            
                SizedBox(height: 5),
            
                MyTextfield(controller: passwordController, hintText: 'Password', obscureText: true),
            
                SizedBox(height: 25),
            
                MyButton(onTap: () => onLogin(context), text: 'Sign In'),
            
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Not a member ?'),
                      TextButton(onPressed: onTap, child: Text('Register Now', style: TextStyle(fontWeight: FontWeight.bold)))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}