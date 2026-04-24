import 'package:chat/components/my_drawer.dart';
import 'package:chat/components/my_post.dart';
import 'package:chat/components/my_textfield.dart';
import 'package:chat/services/post/post_service.dart';
import 'package:flutter/material.dart';

class SocialPage extends StatelessWidget {
  SocialPage({super.key});
  final TextEditingController postController = TextEditingController();
  final PostService _postService = PostService();

  void postMessage(){
    if(postController.text.isEmpty){
      return;
    }
      _postService.addPost(postController.text);
      postController.clear();
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(title: const Text('Social')),
      drawer: const MyDrawer(),
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: MyTextfield(
                      controller: postController,
                      hintText: 'Say sometrhing...',
                      obscureText: false,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: IconButton(
                      onPressed: postMessage,
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
              StreamBuilder(
                stream: _postService.getPostsStream(),
                builder: (context, snapshot){
                  if(snapshot.hasError){
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator());
                  }

                  final posts = snapshot.data!.docs;

                  if(posts.isEmpty || snapshot.data == null){
                    return const Center(child: Text('No posts yet.'));
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index){
                        final post = posts[index];
                        return MyPost(post: post);
                      },
                      ),
                  );

                })
            ],
          ),
        ),
      ),
    );
  }
  
}
