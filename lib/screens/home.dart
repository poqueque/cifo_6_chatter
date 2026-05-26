import 'package:chatter/screens/splash.dart';
import 'package:chatter/services/data_provider.dart';
import 'package:chatter/styles/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.chat, color: AppStyles.balticblue),
        title: Text("Chatter"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Splash()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
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
                          ListTile(title: Text(message.content)),
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
}
