import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? username;
  final currentUser = FirebaseAuth.instance.currentUser; // Current logged-in user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search User",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(size: 24),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Username",
              ),
              onChanged: (value) {
                username = value;
                setState(() {});
              },
            ),
            const SizedBox(
              height: 20,
            ),
            if (username != null && username!.length > 4)
              Flexible(
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .where("username", isEqualTo: username)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                      return const Text("No User Found");
                    }

                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];

                        // ID of the searched user
                        String searchedUserId = documentSnapshot.id;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                          leading: const Icon(
                            Icons.person_outline,
                            color: Colors.black45,
                            size: 20,
                          ),
                          title: Text(
                            documentSnapshot["username"],
                            maxLines: 2,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          tileColor: Colors.indigo.shade50,
                          dense: true,
                          minLeadingWidth: 5,
                          horizontalTitleGap: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          trailing: FutureBuilder<DocumentSnapshot>(
                            future: documentSnapshot.reference
                                .collection("followers")
                                .doc(currentUser!.uid)
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }

                              final isFollowing = snapshot.data?.exists ?? false;

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _chat(documentSnapshot),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(80, 30),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text("Chat"),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (isFollowing) {
                                        // Unfollow logic: remove from both collections
                                        await _unfollowUser(searchedUserId);
                                      } else {
                                        // Follow logic: add to both collections
                                        await _followUser(searchedUserId);
                                      }

                                      setState(() {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(90, 30),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      elevation: 0,
                                      maximumSize: const Size(90, 30)
                                    ),
                                    child: Text(isFollowing ? "Unfollow" : "Follow"),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Method to follow user
  Future<void> _followUser(String searchedUserId) async {
    final batch = FirebaseFirestore.instance.batch();

    // Add searched user to current user's followings collection
    final followingsRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .collection("followings")
        .doc(searchedUserId);

    batch.set(followingsRef, {
      "time": DateTime.now(),
    });

    // Add current user to searched user's followers collection
    final followersRef = FirebaseFirestore.instance
        .collection("users")
        .doc(searchedUserId)
        .collection("followers")
        .doc(currentUser!.uid);

    batch.set(followersRef, {
      "time": DateTime.now(),
    });

    await batch.commit();
  }

  // Method to unfollow user
  Future<void> _unfollowUser(String searchedUserId) async {
    final batch = FirebaseFirestore.instance.batch();

    // Remove searched user from current user's followings collection
    final followingsRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .collection("followings")
        .doc(searchedUserId);

    batch.delete(followingsRef);

    // Remove current user from searched user's followers collection
    final followersRef = FirebaseFirestore.instance
        .collection("users")
        .doc(searchedUserId)
        .collection("followers")
        .doc(currentUser!.uid);

    batch.delete(followersRef);

    await batch.commit();
  }

  void _chat(DocumentSnapshot documentSnapshot) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("chats").where(
      "users",
      arrayContains: FirebaseAuth.instance.currentUser!.uid,
    ).get();

    if (querySnapshot.docs.isEmpty) {
      // Create New Chat
      var data = {
        "users": [
          FirebaseAuth.instance.currentUser!.uid,
          documentSnapshot.id,
        ],
        "recent_text": "Hi",
      };
      await FirebaseFirestore.instance.collection("chats").add(data);
    } else {
      // Start Chat
    }
  }
}
