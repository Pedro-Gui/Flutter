import 'dart:convert'; // Necessário para o base64Decode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_mongo/services/profile/profile_controller.dart';

class UserAvatar extends ConsumerWidget {
  final String userId;
  final double radius;
  const UserAvatar({super.key, required this.userId, this.radius = 20.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picAsync = ref.watch(userProfilePicProvider(userId));
    return picAsync.when(
      data: (base64String) {
        if (base64String == null || base64String.isEmpty) {
          return _buildFallback(context);
        }

        try {
          final String cleanBase64 = base64String.contains(',') 
              ? base64String.split(',').last 
              : base64String;

          return CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(base64Decode(cleanBase64)),
          );
        } catch (_) {
          return _buildFallback(context);
        }
      },
      loading: () => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey,
        child: SizedBox(
          width: radius,
          height: radius,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => _buildFallback(context),
    );
   
  }
  Widget _buildFallback(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: const Icon(Icons.person),
    );
  }
}