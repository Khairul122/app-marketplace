import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(const OotdayApp());
}

class OotdayApp extends StatefulWidget {
  const OotdayApp({super.key});

  @override
  State<OotdayApp> createState() => _OotdayAppState();
}

class _OotdayAppState extends State<OotdayApp> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = await AuthService().restoreSession();
    if (!mounted) return;
    setState(() {
      _loggedIn = user != null;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ootday Pelanggan',
      debugShowCheckedModeBanner: false,
      home: _checking
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (_loggedIn ? const HomeScreen() : const WelcomeScreen()),
    );
  }
}
