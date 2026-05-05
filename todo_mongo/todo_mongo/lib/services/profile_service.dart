import 'package:flutter/material.dart';
import 'package:dart_meteor/dart_meteor.dart';

class ProfileService extends ChangeNotifier {
  final MeteorClient _meteor;
  final Map<String, String> _profilePicsCache = {};

  ProfileService(this._meteor);

  Future<void> editUserProfile(Map<String, dynamic> doc) async {
    try {
      await _meteor.call('EditUser', args: [doc]).timeout(const Duration(seconds: 15));

      final userId = _meteor.userIdCurrentValue();
      if (userId != null) _profilePicsCache.remove(userId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getProfilePic(String id) async {
    if (_profilePicsCache.containsKey(id)) {
      return _profilePicsCache[id];
    }
    try {
      final result = await _meteor.call('getUserPic', args: [id]);
      if (result != null && result['imagem'] != null) {
        _profilePicsCache[id] = result['imagem'];
        return result['imagem'];
      }
      return null;
    } catch (e) {
      rethrow;
    }   
  }

}