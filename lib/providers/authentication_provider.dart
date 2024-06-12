import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      throw error.message ?? 'Sign in failed';
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String surname,
    required File image,
  }) async {
    try {
      final userCredentials =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredentials.user!.uid;

      final storageRef =
          _storage.ref().child('user_images').child('$userId.jpg');
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'username': username,
        'surname': surname,
        'email': email,
        'image_url': imageUrl,
        'is_online': false,
        'last_active': '',
      });

      notifyListeners();
    } on FirebaseAuthException catch (error) {
      throw error.message ?? 'Sign up failed';
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners();
  }
}
