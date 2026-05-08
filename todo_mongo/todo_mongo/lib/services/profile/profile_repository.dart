import 'package:dart_meteor/dart_meteor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_mongo/services/meteor_provider.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final MeteorClient _meteor;

  const ProfileRepository(this._meteor);

  Future<void> editUserProfile(Map<String, dynamic> doc) async {
    await _meteor.call('EditUser', args: [doc]).timeout(const Duration(seconds: 15));
  }

  Future<String?> getUserPic(String targetUserId) async {
    final result = await _meteor.call('getUserPic', args: [targetUserId]);
    
    if (result != null && result is Map && result['imagem'] != null) {
      return result['imagem'] as String;
    }
  
    return null;
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.watch(meteorClientProvider));
}