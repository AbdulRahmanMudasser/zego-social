import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zegosocial/views/chat/views/chat_page.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(size: 24),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("chats")
            .where(
              "users",
              arrayContains: FirebaseAuth.instance.currentUser!.uid,
            )
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
            return const Text("No Chats Found");
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(documentSnapshot: documentSnapshot),
                      ),
                    );
                  },
                  title: const Text(
                    "Username",
                    maxLines: 2,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(documentSnapshot["recent_text"]),
                  tileColor: Colors.indigo.shade50,
                  dense: true,
                  minLeadingWidth: 5,
                  horizontalTitleGap: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black45,
                    size: 18,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
