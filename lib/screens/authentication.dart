import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:test_chat/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() {
    return _AuthenticationState();
  }
}

class _AuthenticationState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _isAuthenticating = false;
  var _enteredUsername = '';
  var _enteredSurname = '';
  String? _email;
  String? _password;
  File? _selectedImage;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (!_isLogin && _selectedImage == null) {
      return;
    }

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _email!, password: _password!);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _email!, password: _password!);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'surname': _enteredSurname,
          'email': _email,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  _isLogin ? 'Sign in' : 'Sign Up',
                  style: const TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
              Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: _isLogin
                    ? const EdgeInsets.all(20)
                    : const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: _isLogin
                                ? null
                                : UserImagePicker(
                                    onPickImage: (pickedImage) {
                                      _selectedImage = pickedImage;
                                    },
                                  ),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text(
                                'Email Address',
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            maxLength: 50,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _email = newValue;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text(
                                  'Username',
                                ),
                              ),
                              enableSuggestions: false,
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              maxLength: 10,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length <= 4) {
                                  return 'Enter a valid Username';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredUsername = newValue!;
                              },
                            ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text(
                                  'Surname',
                                ),
                              ),
                              enableSuggestions: false,
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              maxLength: 10,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length <= 1) {
                                  return 'Enter a valid Surname';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredSurname = newValue!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Password'),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password should be at least 6 characters long';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _password = newValue;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(
                                _isLogin ? 'Login' : 'Sign up',
                              ),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
