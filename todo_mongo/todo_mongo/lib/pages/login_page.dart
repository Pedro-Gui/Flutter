import 'package:dart_meteor/dart_meteor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/components/my_button.dart';
import 'package:todo_mongo/components/my_textfield.dart';
import 'package:todo_mongo/components/square_tile.dart';
import 'package:todo_mongo/services/mongo_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  MongoService? mongoService;

  void onSingUserIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await mongoService!.loginWithEmail(
        usernameController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } on MeteorError catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      String message = 'Credenciais inválidas.';

      final reason = e.reason?.toLowerCase() ?? '';

      if (reason.contains('user not found')) {
        message = 'Usuário não encontrado.';
      } else if (reason.contains('incorrect password')) {
        message = 'Senha incorreta.';
      } else if (reason.contains('too many requests')) {
        message =
            'Muitas tentativas. Por favor, aguarde um momento e tente novamente.';
      } else {
        message = e.message.toString();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
  
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão. Verifique sua internet.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    usernameController.text = 'teste@teste.com';
    passwordController.text = '123';
    mongoService = Provider.of<MongoService>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/images/synergia.png', height: 200, width: 200),

                const SizedBox(height: 50),

                Text(
                  'Welcome to Synergia',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                MyTextfield(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot password ?',
                        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                MyButton(onTap: onSingUserIn, text: 'Sign In'),

                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Theme.of(context).colorScheme.primary),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.5, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SquareTile(
                        imagePath: 'lib/images/google.png',
                        onTap: () {
                          mongoService!.signInWithGoogle();
                        },
                      ),
                      SquareTile(
                        imagePath: 'lib/images/apple.png',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        ' Register Now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
