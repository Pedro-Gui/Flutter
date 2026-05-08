import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/my_drawer.dart';
import '../components/edit_profile_form.dart';
import '../components/user_avatar.dart';
import '../models/user_model.dart';
import '../services/auth/auth_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  
  void _showEditSheet(User user) {
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
    final userAsync = ref.watch(authControllerProvider);

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
      body: switch (userAsync) {
        AsyncData(:final value) => value != null 
            ? _buildProfileData(value) 
            : const Center(child: Text('Faça login para ver seu perfil.')),
        AsyncError(:final error) => Center(child: Text('Erro ao carregar perfil: $error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
     
      floatingActionButton: userAsync.value != null
          ? FloatingActionButton(
              onPressed: () => _showEditSheet(userAsync.value!),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildProfileData(User user) {
    final profile = user.profile ?? {};

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserAvatar(
              userId: user.id,
              radius: 60.0,
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
                  _buildInfoRow('Username', user.username.toUpperCase()),
                  _buildInfoRow('Email', user.emails.isNotEmpty ? user.emails.first : 'N/A'),
                  const Divider(height: 30),
                  _buildInfoRow('Nome', '${profile['firstname'] ?? ''} ${profile['lastname'] ?? ''}'),
                  _buildInfoRow('Empresa', profile['empresa'] ?? 'Não informado'),
                  _buildInfoRow('Sexo', profile['sexo'] ?? 'Não informado'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final displayValue = value.trim().isEmpty ? 'N/A' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: Text(
              displayValue,
              style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}