import 'package:chat/components/my_chat_tile.dart';
import 'package:chat/components/my_textfield.dart';
import 'package:chat/services/auth/auth_service.dart';
import 'package:chat/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUsername;
  final String receiverID;
  const ChatPage({super.key, required this.receiverUsername, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

 final FocusNode _focusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), ()=> scrollDown());
      }
    });
    Future.delayed(const Duration(milliseconds: 500), ()=> scrollDown());
  }
  @override
  void dispose() {
    _focusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  } 

  void sendMessage() async {
    if (messageController.text.isEmpty) {
      return;
    }
    await _chatService.sendMessage(widget.receiverID, messageController.text);

    messageController.clear();

    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverUsername), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildUserInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessage(widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc, BuildContext context) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final bool isCurrentUser =
        data['senderID'] == _authService.getCurrentUser()?.uid;

    return MyChatTile(data: data, isCurrentUser: isCurrentUser);
  }

  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: MyTextfield(
            controller: messageController,
            hintText: 'Type a message',
            obscureText: false,
            focusNode: _focusNode,
          ),
        ),

        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
          ),
        ),
      ],
    );
  }
}
