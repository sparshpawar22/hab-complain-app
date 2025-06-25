import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend1/apis/authentication/login.dart';
import 'package:frontend1/screen1/home_screen1.dart';
import 'package:frontend1/screens/login_screen.dart';
import 'package:frontend1/screen1/qr_scanner.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInDialog extends StatefulWidget {
  const GoogleSignInDialog({super.key});

  @override
  State<GoogleSignInDialog> createState() => _GoogleSignInDialogState();
}

class _GoogleSignInDialogState extends State<GoogleSignInDialog> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _loading = true;
    });

    try {
      final GoogleSignIn googleSignIn =
          GoogleSignIn(scopes: ["profile", "email"]);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign-in was canceled by the user.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Google authentication failed: Missing tokens.');
        return;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print('Signed in as: ${userCredential.user?.displayName}');
      final prefs = await SharedPreferences.getInstance();
      final googleName = userCredential.user?.displayName ?? "Not Provided";
      prefs.setString('googleUsername', googleName);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => homescreen1(),
          ),
        );
      }
    } catch (e) {
      print('Error during Google sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during Google sign-in.')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void showSignInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Login')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context)
                        .pop(); //A bug here because of it i guess linear progress bar doesnt show
                    await signInWithGoogle();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/google.svg',
                        height: 24.0,
                      ),
                      const SizedBox(width: 10),
                      const Text('Sign in with Google'),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      await signInWithApple();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => homescreen1()));
                    },
                    child: Text("Apple sign in"))
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () => showSignInDialog(context),
            child: const Text('Sign in'),
          ),
        ),
      ],
    );
  }
}

Future<void> signOut(context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const loginScreen(),
    ),
    (route) => false,
  );
}
