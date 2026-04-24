// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
// os dois metodos funcionam 
//AuthService.signInWithGoogle() e AuthServiceWithToken().signInWithGoogle(),
// o negocio é que o primeiro é do fireBase e abre uma pagina no google para logar
// o segundo é do Google e abre um pop up nativo do android para  logar

class AuthService {
  
  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      return await FirebaseAuth.instance.signInWithProvider(googleProvider);
      
    } on FirebaseAuthException catch (e) {
      print("||||||||| Erro no Firebase Auth: ${e.code} ||||||||||||");
      return null;
    } catch (e) {
      print("||||||||||| Erro inesperado durante o Google Sign-In: $e |||||||||||");
      return null;
    }
  }
  
}

class AuthServiceWithToken {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<bool> signInWithGoogle() async {
    try {
      // 1. Inicialização obrigatória
      await _googleSignIn.initialize();

      if (!_googleSignIn.supportsAuthenticate()) {
        print("Plataforma não suporta 'authenticate'");
        return false;
      }

      final completer = Completer<GoogleSignInAccount?>();
      late StreamSubscription subscription;

      subscription = _googleSignIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          completer.complete(event.user);
          subscription.cancel();
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          completer.complete(null);
          subscription.cancel();
        }
      }, onError: (error) {
        completer.completeError(error);
        subscription.cancel();
      });

      // 2. Autenticação com scopeHint
      await _googleSignIn.authenticate(scopeHint: ['email']);

      final GoogleSignInAccount? googleUser = await completer.future.timeout(
        const Duration(minutes: 1),
        onTimeout: () => null,
      );

      if (googleUser == null) return false;

      // --- MUDANÇA PARA ACESSAR O ACCESS TOKEN (v7.x) ---
      
      // 3. Usamos o authorizationClient para gerenciar os escopos
      final authClient = _googleSignIn.authorizationClient;
      
      // 4. Tentamos obter a autorização para o escopo de email
      var authorization = await authClient.authorizationForScopes(['email']);

      // 5. Se não houver autorização prévia, solicitamos ao usuário
      authorization ??= await authClient.authorizeScopes(['email']);

      // 6. O idToken ainda vem da propriedade authentication (síncrona)
      final googleAuth = googleUser.authentication;

      // 7. Criamos a credencial usando o accessToken do authorizationClient
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken, // Token obtido via authorizationClient
        idToken: googleAuth.idToken,           // ID Token obtido via authentication
      );

      await _auth.signInWithCredential(credential);
      return true;

    } catch (e) {
      print("Erro no Google Sign-In v7: $e");
      return false;
    }
  }
}