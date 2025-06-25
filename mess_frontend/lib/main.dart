import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:frontend1/apis/authentication/login.dart';
import 'package:frontend1/screens/Home_screen.dart';
import 'package:frontend1/screens/login_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool asLoggedIn = await isLoggedIn();
  runApp(MyApp(isLoggedIn: asLoggedIn));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();

    // Use `.map()` to transform the stream into a stream of ConnectivityResult
    _connectivityStream = _connectivity.onConnectivityChanged
        .map((List<ConnectivityResult> results) => results.isNotEmpty ? results[0] : ConnectivityResult.none);

    _connectivityStream.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _showNoInternetDialog();
    } else {
      if (_isDialogShowing) {
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        _isDialogShowing = false;
      }
    }
  }

  void _showNoInternetDialog() {
    if (!_isDialogShowing) {
      _isDialogShowing = true;
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false, // Prevent dismissal by tapping outside
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text("No Internet Connection"),
            content: Text("Please check your internet connection."),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: widget.isLoggedIn ? HomeScreen() : loginScreen(),
      builder: EasyLoading.init(),
    );
  }

  @override
  void dispose() {
    // Dispose of the connectivity stream if necessary
    super.dispose();
  }
}
