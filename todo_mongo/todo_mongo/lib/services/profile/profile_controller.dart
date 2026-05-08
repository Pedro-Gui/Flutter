import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_controller.dart';
import 'profile_repository.dart';

part 'profile_controller.g.dart';


@Riverpod(keepAlive: true)
Future<String?> userProfilePic(Ref ref, String userId) async {
  //print('Buscando imagem no server');
  return ref.read(profileRepositoryProvider).getUserPic(userId);
}

@Riverpod(keepAlive: true)
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {
  }

  Future<void> editUserProfile(Map<String, dynamic> doc) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).editUserProfile(doc);

      final currentUser = ref.read(authControllerProvider).value;
      if (currentUser != null) {
        ref.invalidate(userProfilePicProvider(currentUser.id));
      }
    });
  }
}