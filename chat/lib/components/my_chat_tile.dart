import 'package:flutter/material.dart';

class MyChatTile extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isCurrentUser;
  const MyChatTile({
    super.key,
    required this.data,
    required this.isCurrentUser,
  });

  @override
  State<MyChatTile> createState() => _MyChatTileState();
}

class _MyChatTileState extends State<MyChatTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String message = widget.data['message'] ?? '';
    final bool isLongText = message.length > 200;
    final String displayText = (isLongText && !isExpanded)
        ? '${message.substring(0, 200)}...'
        : message;

    return Align(
      alignment: widget.isCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
        constraints: const BoxConstraints(maxWidth: 330),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: widget.isCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.isCurrentUser ? const SizedBox() : const Icon(Icons.person),
            const SizedBox(width: 10),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                
                decoration: BoxDecoration(
                  color: widget.isCurrentUser
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(displayText),
                    if (isLongText) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Text(
                              isExpanded ? 'Ver menos' : 'Ver mais',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.inversePrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            widget.isCurrentUser ? const Icon(Icons.person) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
