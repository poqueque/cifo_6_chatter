import 'package:chatter/screens/home.dart';
import 'package:chatter/services/data_provider.dart';
import 'package:chatter/styles/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late String status;
  final providers = [EmailAuthProvider()];

  @override
  void initState() {
    super.initState();
    status = "Inicialitzant...";
    Future.delayed(Duration.zero, init);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 96, color: AppStyles.balticblue),
            Text(status, style: AppStyles.statusStyle),
          ],
        ),
      ),
    );
  }

  Future<void> init() async {
    status = "Conectant a Firebase";
    setState(() {});
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("Not logged");
      // Go to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<UserCreated>((context, state) {
                navigateHome(context);
              }),
              AuthStateChangeAction<SignedIn>((context, state) {
                navigateHome(context);
              }),
            ],
          ),
        ),
      );
    } else {
      debugPrint("User Logged: ${user.uid} - ${user.displayName}");
      navigateHome(context);
    }
  }

  void navigateHome(BuildContext context) {
    var dataProvider = context.read<DataProvider>();
    dataProvider.init();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }
}
