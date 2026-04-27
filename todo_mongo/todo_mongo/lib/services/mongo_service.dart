import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dart_meteor/dart_meteor.dart';
import 'dart:async';

class MongoService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  late final MeteorClient _meteor;

  MongoService() {
    _meteor = MeteorClient.connect(url: 'ws://10.0.2.2:3000/websocket');
  }

  Stream<DdpConnectionStatus> get connectionStatus => _meteor.status();
  Stream<String?> get authStateChanges => _meteor.userId();
  Stream<Map<String, dynamic>?> get currentUserData => _meteor.user();

  String? get currentUserId => _meteor.userIdCurrentValue();
  String? get currentUsername {
    final userDoc = _meteor.userCurrentValue(); 

    if (userDoc != null && userDoc.containsKey('username')) {
      return userDoc['username'] as String;
    }
    return null;
  }

  Stream<Map<String, dynamic>> get todoCollection => _meteor.collection('TODO');

  // AUTH functions 
  Future<bool> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      if (!_googleSignIn.supportsAuthenticate()) {
        print("Plataforma não suporta 'authenticate'");
        return false;
      }

      final completer = Completer<GoogleSignInAccount?>();
      late StreamSubscription subscription;

      subscription = _googleSignIn.authenticationEvents.listen(
        (event) {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            completer.complete(event.user);
            subscription.cancel();
          } else if (event is GoogleSignInAuthenticationEventSignOut) {
            completer.complete(null);
            subscription.cancel();
          }
        },
        onError: (error) {
          completer.completeError(error);
          subscription.cancel();
        },
      );

      await _googleSignIn.authenticate(scopeHint: ['email']);

      final GoogleSignInAccount? googleUser = await completer.future.timeout(
        const Duration(minutes: 1),
        onTimeout: () => null,
      );

      if (googleUser == null) return false;
      final authClient = _googleSignIn.authorizationClient;
      var authorization = await authClient.authorizationForScopes(['email']);

      authorization ??= await authClient.authorizeScopes(['email']);

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        print("Erro: ID Token não retornado pelo Google.");
        return false;
      }

      await _meteor.login({
        'googleNative': {'idToken': idToken},
      });
      return true;
    } catch (e) {
      print("Erro no Google Sign-In com Meteor: $e");
      return false;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _meteor.loginWithPassword(email, password);
      _meteor.subscribe('listaTodos');
      notifyListeners();
    } catch (e) {
      rethrow; 
    }
  }

  Future<void> createUserWithEmail(String username ,String email, String password) async {
    try {
      await _meteor.call('createUser', args: [{
        'username': username,
        'email': email,
        'password': password,
      }]);
      
      loginWithEmail(email, password); 
    } catch (e) {
      rethrow; 
    }
    
  }

  Future<void> connect() async {
    _meteor.reconnect();
    notifyListeners();
  }

  void disconnect() {
    _meteor.disconnect();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _meteor.logout();
    notifyListeners();
  }

  // CRUD functions
  Future<void> addTask(String title) async {
    try {
      await _meteor.call('tasks.insert', args: [{
        'title': title, 
        'situacao': 'naoConcluido',
        'ownerId': currentUserId,
        'ownerUsername': currentUsername, 
        }]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(String id, String newTitle) async {

    try {
      await _meteor.call('tasks.edit', args: [{'_id': id, 'doc': {
              'title': newTitle,
            }}]);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateSituacao(String id, String situacao) async {
    switch (situacao) {
      case 'concluido':
        situacao = 'naoConcluido';
      case 'emAndamento':
        situacao = 'concluido';
      case 'naoConcluido':
        situacao = 'emAndamento';
      default:
        situacao = 'naoConcluido';
    }
    try {
      await _meteor.call('tasks.toggleSituacao', args: [{'_id':id,'situacao': situacao}]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    
    try {
      await _meteor.call('tasks.delete', args: [{'_id':id}]);
    } catch (e) {
      rethrow;
    }
  }
}
