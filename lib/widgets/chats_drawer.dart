import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _downloading = true;
String _username = "username";

class ChatsDrawer extends ConsumerStatefulWidget {
  const ChatsDrawer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatsDrawerState();
}

class _ChatsDrawerState extends ConsumerState<ChatsDrawer> {
  void getUsername() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    _username = userData.data()!['username'];
    if (_username != "username" && _downloading == true) {
      setState(() {});
      _downloading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    getUsername();
    final themeProvider = ref.read(themeStateProvider.notifier);
    return Drawer(
      width: 200,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                DrawerHeader(
                  // padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(_username),
                  ),
                ),
                ListTile(
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                  leading: const Icon(
                    Icons.dark_mode_rounded,
                  ),
                  title: const Text(
                    "Dark Mode",
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
            leading: const Icon(
              Icons.logout_rounded,
              color: Color.fromARGB(255, 255, 62, 48),
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Color.fromARGB(255, 255, 62, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
