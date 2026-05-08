import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_mongo/models/user_model.dart';
import 'auth_repository.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Stream<User?> build() {
    return ref.watch(authRepositoryProvider).currentUserData;
  }

  Future<bool> signInWithGoogle() async {
    return await ref.read(authRepositoryProvider).signInWithGoogle();
  }

  Future<void> loginWithEmail(String email, String password) async {
    await ref.read(authRepositoryProvider).loginWithEmail(email, password);
  }

  Future<void> createUserWithEmail(String username, String email, String password) async {
    await ref.read(authRepositoryProvider).createUserWithEmail(username, email, password);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}