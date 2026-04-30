import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/components/my_drawer.dart';
import 'package:todo_mongo/components/edit_profile_form.dart';
import 'package:todo_mongo/services/mongo_service.dart';
import 'package:todo_mongo/services/user_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showEditSheet(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditProfileForm(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MongoService mongoService = Provider.of<MongoService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PROFILE',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: StreamBuilder<User?>(
        stream: mongoService.currentUserData,
        builder: (context, snapshot) {
          if (mongoService.currentUserId == null) {
            return const Center(child: Text('Faça login para ver seu perfil.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Faça login para ver seu perfil.'));
          }

          final User user = snapshot.data!;
          final profile = user.profile ?? {};
          final base64Image = profile['imagem'] ?? '';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary.withValues(alpha: 0.1),
                  backgroundImage: base64Image.isNotEmpty 
                      ? MemoryImage(base64Decode(base64Image)) 
                      : null,
                  child: base64Image.isEmpty 
                      ? Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.inversePrimary)
                      : null,
                ),
                const SizedBox(height: 20),
                
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(context, 'Username', user.username.toUpperCase()),
                      _buildInfoRow(context, 'Email', user.emails.isNotEmpty ? user.emails[0] : 'N/A'),
                      const Divider(height: 30),
                      _buildInfoRow(context, 'Nome', '${profile['firstname'] ?? ''} ${profile['lastname'] ?? ''}'),
                      _buildInfoRow(context, 'Empresa', profile['empresa'] ?? 'Não informado'),
                      _buildInfoRow(context, 'Sexo', profile['sexo'] ?? 'Não informado'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: StreamBuilder<User?>(
        stream: mongoService.currentUserData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _showEditSheet(context, snapshot.data!),
            child: const Icon(Icons.edit),
          );
        }
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(
              value.isEmpty ? 'N/A' : value, 
              style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}