import 'package:chat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data();
      }).toList();
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser() async {
    print(_auth.currentUser!.email!);
    return _firestore.collection('Users').doc(_auth.currentUser!.uid).get();
  }

  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserName = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMsg = Message(
      senderID: currentUserId,
      senderEmail: currentUserName,
      receiverID: receiverID,
      timestamp: timestamp,
      message: message,
    );

    final List<String> ids = [currentUserId, receiverID];
    ids.sort();
    final String chatID = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatID)
        .collection('messages')
        .add(newMsg.toMap());
  }

  Stream<QuerySnapshot> getMessage(String receiverID) {
    final String currentUserId = _auth.currentUser!.uid;

    final List<String> ids = [currentUserId, receiverID];
    ids.sort();
    final String chatID = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
