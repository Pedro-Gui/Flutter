import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dart_meteor/dart_meteor.dart';
import 'package:todo_mongo/services/filter_model.dart';
import 'dart:async';

import 'package:todo_mongo/services/task_model.dart';
import 'package:todo_mongo/services/user_model.dart';

//SHA1: DF:8B:B4:48:27:61:6D:8A:A0:7D:C4:C0:30:D7:7C:87:12:0C:6D:4F
class MongoService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  late final MeteorClient _meteor;

  SubscriptionHandler? _tasksSubscription;
  TaskFilter _filter = TaskFilter();
  int _totalTasks = 0;
  int _totalPages = 1;
  final int _itemsPerPage = 6;

  MongoService() {
    _meteor = MeteorClient.connect(url: 'ws://10.0.2.2:3000/websocket');
  }

  Stream<DdpConnectionStatus> get connectionStatus => _meteor.status();
  Stream<String?> get authStateChanges => _meteor.userId();
  Stream<User?> get currentUserData {
    return _meteor.user().map((userMap) {
      if (userMap == null) {
        return null;
      }
      return User.fromMap(userMap);
    });
  }

  String? get currentUserId => _meteor.userIdCurrentValue();
  String? get currentUsername {
    final userDoc = _meteor.userCurrentValue();

    if (userDoc != null && userDoc.containsKey('username')) {
      return userDoc['username'] as String;
    }
    return null;
  }

  Stream<List<Task>> get todoCollection {
    return _meteor.collection('TODO').map((mapaDaColecao) {
      final docs = mapaDaColecao.values;
      return docs.map((doc) {
        return Task.fromMap(doc as Map<String, dynamic>);
      }).toList();
    });
  }

  TaskFilter get filter => _filter;
  int get totalPages => _totalPages;

  // AUTH functions
  Future<bool> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId:
            '611337992795-11e2a9kugrkiq44h67eh01l3ir8hp92d.apps.googleusercontent.com',
      );

      if (!_googleSignIn.supportsAuthenticate()) {
        //print("Plataforma não suporta 'authenticate'");
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
        //print("Erro: ID Token não retornado pelo Google.");
        return false;
      }

      await _meteor.login({
        'googleNative': {'idToken': idToken},
      });

      updateSubscribe();
      notifyListeners();
      return true;
    } catch (e) {
      //print("Erro no Google Sign-In com Meteor: $e");
      return false;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _meteor.loginWithPassword(email, password);
      updateSubscribe();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUserWithEmail(
    String username,
    String email,
    String password,
  ) async {
    try {
      await _meteor.call(
        'createUser',
        args: [
          {'username': username, 'email': email, 'password': password},
        ],
      );

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
    _tasksSubscription?.stop();
    _meteor.logout();
    notifyListeners();
  }

  // CRUD functions
  Future<void> _fetchTotalPages() async {
    try {
      final total = await _meteor.call(
        'tasks.countTotal',
        args: [_filter.hideCompleted, _filter.search],
      );

      _totalTasks = (total as num).toInt();
      _totalPages = (_totalTasks / _itemsPerPage).ceil();
      if (_totalPages == 0) _totalPages = 1; 
    }catch (e) {
      rethrow;
    }
  }

  Future<void> updateSubscribe() async {
    _tasksSubscription?.stop();
    _tasksSubscription = _meteor.subscribe('tasks', args: _filter.toArgs());
    await _fetchTotalPages();
  }

  Future<void> addTask(Task task) async {
    try {
      await _meteor.call('tasks.insert', args: [task.toMapEdit()]);
      _fetchTotalPages();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _meteor.call(
        'tasks.edit',
        args: [
          {'_id': task.id, 'doc': task.toMapEdit()},
        ],
      );
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
      await _meteor.call(
        'tasks.toggleSituacao',
        args: [
          {'_id': id, 'situacao': situacao},
        ],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _meteor.call(
        'tasks.delete',
        args: [
          {'_id': id},
        ],
      );
      _fetchTotalPages();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleCompleted() async {
    _filter.hideCompleted = !_filter.hideCompleted;
    await updateSubscribe();
    notifyListeners();
  }

  void nextPage() {
    if (_filter.pagina < 1 || _filter.pagina >= _totalPages) {
      _filter.pagina = 1;
      updateSubscribe();
    } else {
      _filter.pagina++;
      updateSubscribe();
    }
  }

  void previousPage() {
    if (_filter.pagina <= 1) {
      _filter.pagina = _totalPages; 
    } 
    else {
      _filter.pagina--;
    }
    updateSubscribe();
  }

  void setSearch(String texto) {
    _filter.search = texto.isEmpty ? null : texto;
    updateSubscribe();
  }
}
