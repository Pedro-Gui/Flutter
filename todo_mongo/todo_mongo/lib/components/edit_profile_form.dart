import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:todo_mongo/models/user_model.dart';
import 'package:todo_mongo/services/profile/profile_controller.dart';

class EditProfileForm extends ConsumerStatefulWidget {
  final User user;

  const EditProfileForm({super.key, required this.user});

  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm> {
  late final TextEditingController _usernameController;
  late final TextEditingController _firstnameController;
  late final TextEditingController _lastnameController;
  late final TextEditingController _empresaController;
  
  String _selectedSexo = 'Masculino';
  DateTime _selectedDate = DateTime.now();
  String _base64Image = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.user.profile ?? {};
    
    _usernameController = TextEditingController(text: widget.user.username);
    _firstnameController = TextEditingController(text: profile['firstname'] ?? '');
    _lastnameController = TextEditingController(text: profile['lastname'] ?? '');
    _empresaController = TextEditingController(text: profile['empresa'] ?? '');
    
    _selectedSexo = profile['sexo'] ?? 'Masculino';
    _base64Image = profile['imagem'] ?? '';
    
    if (profile['dataNasc'] != null) {
      _selectedDate = DateTime.parse(profile['dataNasc'].toString());
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _empresaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
     final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
     if (image != null) {
       final bytes = await image.readAsBytes();
       setState(() => _base64Image = base64Encode(bytes));
     }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_firstnameController.text.isEmpty || _lastnameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e sobrenome são obrigatórios.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doc = {
        'username': _usernameController.text.trim(),
        'firstname': _firstnameController.text.trim(),
        'lastname': _lastnameController.text.trim(),
        'empresa': _empresaController.text.trim(),
        'sexo': _selectedSexo,
        'dataNasc': _selectedDate.toIso8601String(),
        'imagem': _base64Image, 
      };

      await ref.read(profileControllerProvider.notifier).editUserProfile(doc);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Editar Perfil', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _base64Image.isNotEmpty 
                    ? MemoryImage(base64Decode(_base64Image)) 
                    : null,
                child: _base64Image.isEmpty ? const Icon(Icons.camera_alt) : null,
              ),
            ),
            
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _firstnameController, decoration: const InputDecoration(labelText: 'First Name')),
            TextField(controller: _lastnameController, decoration: const InputDecoration(labelText: 'Last Name')),
            TextField(controller: _empresaController, decoration: const InputDecoration(labelText: 'Company')),
            
            DropdownButtonFormField<String>(
              initialValue: _selectedSexo,
              items: ['Masculino', 'Feminino', 'Outro'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSexo = val!),
              decoration: const InputDecoration(labelText: 'Sex'),
            ),
            
            ListTile(
              title: Text('Birth Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            
            const SizedBox(height: 16),
            _isLoading 
                ? const CircularProgressIndicator() 
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Salvar Alterações'),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}