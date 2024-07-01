import 'dart:developer';

import 'package:chatapp/widgets/chat_msg.dart';
import 'package:chatapp/widgets/chats_drawer.dart';
import 'package:chatapp/widgets/new_msg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

final firebase = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPuchhNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    final token = await fcm.getToken();
    log(token.toString());
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setupPuchhNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      // drawer: fetchUserData(),
      drawer: ChatsDrawer(),
      appBar: AppBar(
        title: const Text("ChatApp"),
      ),
      body: const Column(
        children: [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
