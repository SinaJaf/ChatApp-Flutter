import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/screens/auth.dart';
import 'package:chatapp/screens/chat.dart';
import 'package:chatapp/screens/splash.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        // Handle authentication state based on snapshot data (similar to your code)

        // Replace with your actual widgets based on authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData) {
          return ChatScreen(); // Replace with actual ChatScreen widget
        }

        return const AuthScreen(); // Replace with actual AuthScreen widget
      },
    );
  }
}
