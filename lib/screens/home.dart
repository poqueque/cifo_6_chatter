import 'package:chatter/screens/splash.dart';
import 'package:chatter/styles/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text("Home Page"),
            Text(FirebaseAuth.instance.currentUser!.displayName ?? "---"),
            Text(FirebaseAuth.instance.currentUser!.email ?? "---"),
            Text(FirebaseAuth.instance.currentUser!.phoneNumber ?? "---"),
          ],
        ),
      ),
    );
  }
}
