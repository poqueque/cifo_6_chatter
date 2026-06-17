import 'package:chatter/screens/splash.dart';
import 'package:chatter/services/data_provider.dart';
import 'package:chatter/styles/app_styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => DataProvider(),
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: .fromSeed(seedColor: Colors.deepPurple),
          fontFamily: GoogleFonts.montserrat().fontFamily,
          scaffoldBackgroundColor: AppStyles.aliceBlue,
          appBarTheme: AppBarTheme(backgroundColor: AppStyles.vividTangerine),
        ),
        home: Splash(),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Rebut un background message: ${message.messageId}");
}
