import 'package:chat/services/auth/auth_service.dart';
import 'package:chat/components/my_button.dart';
import 'package:chat/components/my_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final void Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  void onSignUp(BuildContext context) async{
    if(passwordController.text != confirmPasswordController.text){
      ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Confirme sua senha!')));

      return;
    }

    try{
         AuthService().signUpWithEmailAndPassword(usernameController.text, emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/images/wolf.png', height: 200, width: 200),
            
                const SizedBox(height: 15),
            
                const Text(
                  'Let\'s create an account!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),
            
                MyTextfield(controller: usernameController, hintText: 'Username', obscureText: false),

                const SizedBox(height: 5),
            
                MyTextfield(controller: emailController, hintText: 'Email', obscureText: false),
            
                const SizedBox(height: 5),
            
                MyTextfield(controller: passwordController, hintText: 'Password', obscureText: true),

                const SizedBox(height: 5),
            
                MyTextfield(controller: confirmPasswordController, hintText: 'Confirm password', obscureText: true),
            
                const SizedBox(height: 25),
            
                MyButton(onTap: () => onSignUp(context), text: 'Sign Up'),
            
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Already a member ?'),
                      TextButton(onPressed: onTap, child: const Text('Login Now', style: TextStyle(fontWeight: FontWeight.bold)))
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