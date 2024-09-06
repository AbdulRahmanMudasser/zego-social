import 'package:flutter/material.dart';
import 'package:zegosocial/views/chat/views/chat_list.dart';
import 'package:zegosocial/views/home/views/home_page.dart';
import 'package:zegosocial/views/live/views/live_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final TextEditingController _postController;

  int _index = 0;

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
      body: IndexedStack(
        index: _index,
        children: const [
          HomePage(),
          ChatList(),
          LivePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _index,
      onTap: (value) {
        setState(() {
          _index = value;
        });
      },
      elevation: 0,
      backgroundColor: Colors.white,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      type: BottomNavigationBarType.fixed,
      iconSize: 22,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.public_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mode_comment_outlined),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.live_tv_outlined),
          label: 'Live',
        ),
      ],
    );
  }
}
