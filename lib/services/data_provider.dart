import 'package:chatter/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  List<Message> messages = [];

  void init() {
    loadMessages();
  }

  final db = FirebaseFirestore.instance;
  final docRef = FirebaseFirestore.instance
      .collection("chatRoom")
      .doc("room1")
      .collection("messages")
      .withConverter(
        fromFirestore: Message.fromFirestore,
        toFirestore: (Message message, options) => message.toFirestore(),
      );

  Future<void> addMessage(String content) async {
    var message = Message(
      uid: FirebaseAuth.instance.currentUser?.uid ?? "Anonymous",
      content: content,
      dateTime: DateTime.now(),
    );

    await docRef.add(message);
    notifyListeners();
  }

  void loadMessages() {
    docRef.snapshots().listen((event) {
      messages.clear();
      for (var doc in event.docs) {
        messages.add(doc.data());
      }
      messages.sort();
      notifyListeners();
    }, onError: (error) => debugPrint("Error: $error"));
  }
}
