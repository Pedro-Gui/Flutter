

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference _posts = FirebaseFirestore.instance.collection('Posts');

  Future<void> addPost(String message){
    return _posts.add({
      'UserEmail': user!.email,
      'Message': message,
      'TimeStamp': Timestamp.now()
    });
  }

  Stream<QuerySnapshot> getPostsStream(){
    final postsStream = FirebaseFirestore.instance.collection('Posts').orderBy('TimeStamp', descending: true).snapshots();

    return postsStream;
  }
}  