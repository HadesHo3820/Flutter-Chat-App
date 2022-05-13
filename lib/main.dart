import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat_app/allConstants/app_constants.dart';
import 'package:ichat_app/allProviders/auth_provider.dart';
import 'package:ichat_app/allProviders/chat_provider.dart';
import 'package:ichat_app/allProviders/home_provider.dart';
import 'package:ichat_app/allProviders/navigation_provider.dart';
import 'package:ichat_app/allProviders/setting_provider.dart';
import 'package:ichat_app/allProviders/theme_provider.dart';
import 'package:ichat_app/allScreens/splash_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isWhite = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({required this.prefs});

  @override
  Widget build(BuildContext context) {
    bool? isDarkTheme = prefs.getBool('theme');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(
                firebaseAuth: FirebaseAuth.instance,
                googleSignIn: GoogleSignIn(),
                prefs: prefs,
                firebaseFirestore: firebaseFirestore)),
        ChangeNotifierProvider(
            create: (_) => ThemeProvider(
                mode: isDarkTheme != null
                    ? isDarkTheme
                        ? ThemeMode.dark
                        : ThemeMode.light
                    : ThemeMode.system)),
        Provider(
            create: (_) => SettingProvider(
                prefs: prefs,
                firebaseFirestore: firebaseFirestore,
                firebaseStorage: firebaseStorage)),
        ChangeNotifierProvider(
            create: (_) => HomeProvider(firebaseFirestore: firebaseFirestore)),
        Provider(
            create: (_) => ChatProvider(
                prefs: prefs,
                firebaseFirestore: firebaseFirestore,
                firebaseStorage: firebaseStorage)),
        ChangeNotifierProvider(
          create: (context) => NavigationProvider(),
        )
      ],
      child: Consumer<ThemeProvider>(
        builder: (ctx, themeObject, _) => MaterialApp(
          title: AppConstants.appTitle,
          themeMode: themeObject.themeMode,
          theme: MyTheme.lightTheme,
          darkTheme: MyTheme.darkTheme,
          home: const SplashPage(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
