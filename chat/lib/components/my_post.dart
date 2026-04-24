import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyPost extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> post;
  const MyPost({super.key, required this.post});

  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String message = widget.post['Message'] ?? '';
    final bool isLongText = message.length > 200;
    final String displayText = (isLongText && !isExpanded)
        ? '${message.substring(0, 200)}...'
        : message;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2, // Dá uma leve sombra para destacar o post do fundo
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do Post (Avatar e Email)
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                  child: Text(
                    widget.post['UserEmail'].toString()[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.post['UserEmail'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            // Corpo da Mensagem
            Text(
              displayText,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
            ),

            if (isLongText) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  // Atualiza o estado da tela ao clicar
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? 'Ver menos' : 'Ver mais',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
