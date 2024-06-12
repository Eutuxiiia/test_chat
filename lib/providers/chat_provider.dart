import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> checkConversationExists(String receiverUserId) async {
    final currentUserId = _firebaseAuth.currentUser!.uid;
    final conversationId1 = '${currentUserId}_$receiverUserId';
    final conversationId2 = '${receiverUserId}_$currentUserId';

    final docRef1 = _firestore.collection('chats').doc(conversationId1);
    final docSnapshot1 = await docRef1.get();

    final docRef2 = _firestore.collection('chats').doc(conversationId2);
    final docSnapshot2 = await docRef2.get();

    if (!docSnapshot1.exists && !docSnapshot2.exists) {
      final newConversation = {
        'users': [currentUserId, receiverUserId],
        'lastMessage': '',
        'lastUpdatedAt': Timestamp.now(),
      };
      await docRef1.set(newConversation);
    }
  }

  Future<void> sendMessage(String receiverUserId, String message) async {
    final currentUserId = _firebaseAuth.currentUser!.uid;
    final conversationId1 = '${currentUserId}_$receiverUserId';
    final conversationId2 = '${receiverUserId}_$currentUserId';

    DocumentReference chatDocRef;
    final docSnapshot1 =
        await _firestore.collection('chats').doc(conversationId1).get();
    final docSnapshot2 =
        await _firestore.collection('chats').doc(conversationId2).get();

    if (docSnapshot1.exists) {
      chatDocRef = docSnapshot1.reference;
    } else if (docSnapshot2.exists) {
      chatDocRef = docSnapshot2.reference;
    } else {
      chatDocRef = _firestore.collection('chats').doc(conversationId1);
      await chatDocRef.set({
        'users': [currentUserId, receiverUserId],
        'lastMessage': message,
        'lastUpdatedAt': Timestamp.now(),
      });
    }

    await chatDocRef.collection('messages').add({
      'text': message,
      'createdAt': Timestamp.now(),
      'sendId': currentUserId,
      'receiverId': receiverUserId,
      'read': false,
      'type': 'text',
    });

    await chatDocRef.update({
      'lastMessage': message,
      'lastUpdatedAt': Timestamp.now(),
    });

    notifyListeners();
  }
}
