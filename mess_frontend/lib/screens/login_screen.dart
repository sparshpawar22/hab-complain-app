import 'package:flutter/material.dart';
import 'package:frontend1/apis/authentication/login.dart';
import 'package:frontend1/screens/home_screen.dart';
import 'dart:io';
import 'package:frontend1/widgets/login screen/googlesignin.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend1/widgets/login screen/login_button.dart';
import 'package:frontend1/widgets/common/snack_bar.dart';
import 'package:frontend1/widgets/common/custom_linear_progress.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  var _inprogress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: Platform.isAndroid,
        bottom: Platform.isAndroid,
        child: Stack(
          children: [
            Container(
            ),
            Center(
              // Center the content
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/Handlogo.png',
                    height: 100, // Adjust size as needed
                  ),
                  const SizedBox(height: 20),
                  // Add some space
                  const Text(
                    'IITG HAB',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 150),
                  // Add space between text and button
                  Padding(
                    padding: EdgeInsets.all(30),
                    child: Material(
                      color: Colors.black,
                      // No background color for the container
                      child: InkWell(
                        splashColor: Colors.white,
                        onTap: () async {
                          try {
                            setState(() {
                              _inprogress = true;
                            });
                            await authenticate();
                            setState(() {
                              _inprogress = false;
                            });
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                            );
                            showSnackBar('Successfully Logged In',Colors.black, context);
                          } catch (e) {
                            setState(() {
                              _inprogress = false;
                            });
                            showSnackBar('Something Went Wrong',Colors.black, context);
                          }
                        },
                        child: Padding(
                            padding: EdgeInsets.all(15),
                            child: const LoginButton()),
                      ),
                    ),
                  ),
                  GoogleSignInDialog(),
                ],
              ),
            ),
            Visibility(
              visible: _inprogress,
              child: const CustomLinearProgress(
                text: 'Loading your details,please wait....',
              ),
            )
          ],
        ),
      ),
    );
  }
}



