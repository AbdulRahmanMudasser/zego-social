import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zegosocial/views/search/views/search_page.dart';

import '../../auth/views/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Page",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(size: 24),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            const ListTile(
              title: Text("Settings"),
            ),
            const Spacer(),
            ListTile(
              title: const Text(
                "Sign Out",
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              },
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text("Home Page"),
      ),
    );
  }
}
