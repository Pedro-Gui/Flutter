import 'dart:convert'; // Necessário para o base64Decode
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/services/mongo_service.dart';
// importe o seu mongo_service.dart

class UserAvatar extends StatelessWidget {
  final String userId;
  final double radius;
  const UserAvatar({super.key, required this.userId, this.radius = 20.0});

  @override
  Widget build(BuildContext context) {
    final mongoService = Provider.of<MongoService>(context, listen: false);

    return FutureBuilder<String?>(
      future: mongoService.getProfilePic(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey,
            child: SizedBox(
              width: radius, 
              height: radius, 
              child: const CircularProgressIndicator(strokeWidth: 2)
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: const Icon(Icons.person),
          );
        }
        try {
          String base64String = snapshot.data!;
          if (base64String.contains(',')) {
            base64String = base64String.split(',').last;
          }

          return CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(base64Decode(base64String)),
          );
        } catch (e) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: const Icon(Icons.person),
          );
        }
      },
    );
  }
}