import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zegosocial/views/home/views/widgets/image_post.dart';
import 'package:zegosocial/views/home/views/widgets/text_post.dart';

import '../../auth/views/login_page.dart';
import '../../search/views/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _postController;

  @override
  void initState() {
    super.initState();
    _postController = TextEditingController();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildPostSection(),
            const SizedBox(height: 20),
            _buildPosts(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Feed',
        style: TextStyle(fontSize: 16),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(size: 24),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPostSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _postController,
            decoration: const InputDecoration(
              hintText: 'Write Something to Post',
              hintStyle: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 25),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: _handlePost,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                elevation: 0,
              ),
              child: const Text('Post'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosts() {
    return Expanded(
      child: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('timeline')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              return _buildPost(document['post-id']);
            },
          );
        },
      ),
    );
  }

  Widget _buildPost(String postId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
      builder: (context, postSnapshot) {
        if (!postSnapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        final post = postSnapshot.data!;
        return post['type'] == 'text'
            ? TextPost(text: post['content'])
            : ImagePost(
                text: post['content'],
                url: post['url'],
              );
      },
    );
  }

  Future<void> _handlePost() async {
    if (_postController.text.trim().isEmpty) return;

    final postContent = {
      'time': DateTime.now(),
      'type': 'text',
      'content': _postController.text.trim(),
      'uid': FirebaseAuth.instance.currentUser!.uid,
    };

    await FirebaseFirestore.instance.collection('posts').add(postContent);
    _postController.clear();
    setState(() {});
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 50),
          const ListTile(title: Text('Settings')),
          const Spacer(),
          ListTile(
            title: const Text('Sign Out'),
            onTap: _handleSignOut,
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
          (route) => false,
    );
  }
}
