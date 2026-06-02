import 'dart:io';

import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chatter/screens/splash.dart';
import 'package:chatter/services/data_provider.dart';
import 'package:chatter/styles/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../extensions/date_time_extension.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController controller;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var imageUrl =
        FirebaseAuth.instance.currentUser?.photoURL ??
        "https://static.thenounproject.com/png/5034901-200.png";

    return Scaffold(
      appBar: AppBar(title: Text("Chatter")),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
              ),
              accountName: Text(
                FirebaseAuth.instance.currentUser?.displayName ?? "---",
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? "--",
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Canviar nom d'usuari"),
              onTap: askUserName,
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Canviar image de perfil"),
              onTap: changeImage,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Tancar sessió"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Splash()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Consumer<DataProvider>(
          builder: (context, dataProvider, child) {
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ListView(
                      reverse: true,
                      children: [
                        for (var message in dataProvider.messages)
                          Column(
                            children: [
                              if (!message.isMine)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    top: 16,
                                  ),
                                  child: Align(
                                    alignment: AlignmentGeometry.centerStart,
                                    child: Text(
                                      message.userName,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                              BubbleSpecialOne(
                                text: message.content,
                                isSender: message.isMine,
                                color: (message.isMine)
                                    ? AppStyles.sageGreen
                                    : AppStyles.lightBlue,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Align(
                                  alignment: (message.isMine)
                                      ? AlignmentGeometry.centerEnd
                                      : AlignmentGeometry.centerStart,
                                  child: Text(message.dateTime.humanReadable()),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller,
                      onSubmitted: sendMessage,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hint: Text("Escriu un missatge"),
                        suffixIcon: IconButton(
                          onPressed: () => sendMessage(controller.text),
                          icon: Icon(Icons.send),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void sendMessage(String message) {
    if (message.isEmpty) return;
    var dataProvider = context.read<DataProvider>();
    dataProvider.addMessage(message);
    controller.clear();
  }

  void askUserName() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Nom Usuari"),
        content: TextField(
          keyboardType: TextInputType.emailAddress,
          controller: nameController,
          decoration: InputDecoration(hintText: "Introdueix un nom d'usuari"),
        ),
        actions: [
          TextButton(onPressed: saveUserName, child: Text("GUARDAR")),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL·LAR"),
          ),
        ],
      ),
    );
  }

  Future<void> saveUserName() async {
    var name = nameController.text;
    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    if (!mounted) return;
    Navigator.pop(context);
    setState(() {});
  }

  Future<void> changeImage() async {
    final picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef
          .child("users")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("profile.png");
      await imageRef.putFile(File(image.path));
      String photoURL = await imageRef.getDownloadURL();
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(photoURL);
      setState(() {});
    }
  }
}
