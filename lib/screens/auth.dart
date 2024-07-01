import 'dart:io';

import 'package:chatapp/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  late String enteredEmail;
  late String enteredPassword;
  late String enteredUsername;
  File? _selectedImage;
  var _isAuthenticating = false;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (!isValid || !_isLogin && _selectedImage == null) {
        return;
      }
      _formKey.currentState!.save();
      if (_isLogin) {
        final userCredential = await _firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        print(userCredential);
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCredential.user!.uid}.jpg");
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(
          {
            'username': enteredUsername,
            "email": enteredEmail,
            "image_url": imageUrl,
          },
        );
        print(userCredential);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Authentication Error"),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ref.read(themeStateProvider.notifier);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              color: Theme.of(context).colorScheme.onSecondary,
              onPressed: () {
                themeProvider.toggleTheme();
              },
              icon: const Icon(
                Icons.dark_mode_rounded,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isLogin)
                    UserImagePicker(
                      onPickedImage: (pickedImage) {
                        _selectedImage = pickedImage;
                      },
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(
                        top: 30,
                        bottom: 20,
                        right: 20,
                        left: 20,
                      ),
                      width: 200,
                      child: Image.asset("assets/chat.png"),
                    ),
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_isLogin)
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: "Username",
                                  ),
                                  enableSuggestions: false,
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        value.trim().length < 4) {
                                      return "Please enter at least 4 characters";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    enteredUsername = value!;
                                  },
                                ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "Email Address",
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains("@")) {
                                    return "Please enter a valid email address";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  enteredEmail = value!;
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "Password",
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  enteredPassword = value!;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!_isAuthenticating)
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isLogin ? "Login" : "Sign up"),
                    ),
                  const SizedBox(height: 12.0),
                  if (_isAuthenticating)
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  if (!_isAuthenticating)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      style: const ButtonStyle(
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Text(
                        _isLogin
                            ? "Create an account"
                            : "I already have an account",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<StatefulWidget> createState() {
//     return _AuthScreenState();
//   }
// }

// class _AuthScreenState extends State<AuthScreen> {}
