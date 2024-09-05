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
  final currentUser = FirebaseAuth.instance.currentUser;  // Current logged-in user

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
              height: 30,
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
                        String searchedUserId = documentSnapshot.id; // ID of the searched user

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(documentSnapshot["username"]),
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

                              return ElevatedButton(
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
                                  minimumSize: const Size(100, 35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(isFollowing ? "Unfollow" : "Follow"),
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
}
