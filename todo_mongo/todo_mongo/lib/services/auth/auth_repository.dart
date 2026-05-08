import 'dart:async';
import 'package:dart_meteor/dart_meteor.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_mongo/models/user_model.dart';
import '../meteor_provider.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final MeteorClient _meteor;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._meteor) : _googleSignIn = GoogleSignIn.instance;

  //Stream<DdpConnectionStatus> get connectionStatus => _meteor.status();
  //Stream<String?> get authStateChanges => _meteor.userId();

  Stream<User?> get currentUserData {
    return _meteor.user().map((userMap) {
      if (userMap == null) return null;
      return User.fromMap(userMap);
    });
  }

  //String? get currentUserId => _meteor.userIdCurrentValue();

  /* String? get currentUsername {
    final userDoc = _meteor.userCurrentValue();
    if (userDoc != null && userDoc.containsKey('username')) {
      return userDoc['username'] as String;
    }
    return null;
  } */

  Future<bool> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: '611337992795-11e2a9kugrkiq44h67eh01l3ir8hp92d.apps.googleusercontent.com',
      );
      if (!_googleSignIn.supportsAuthenticate()) return false;

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
      
      if (idToken == null) return false;

      await _meteor.login({
        'googleNative': {'idToken': idToken},
      }).timeout(const Duration(seconds: 5));
      
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _meteor.loginWithPassword(email, password).timeout(const Duration(seconds: 10));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUserWithEmail(String username, String email, String password) async {
    try {
      await _meteor.call(
        'createUser',
        args: [{'username': username, 'email': email, 'password': password}],
      );
      await loginWithEmail(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> connect() async {
    _meteor.reconnect();
  }

  void disconnect() {
    _meteor.disconnect();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _meteor.logout();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final meteorClient = ref.watch(meteorClientProvider);
  return AuthRepository(meteorClient);
}