import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimationAndNavigate();
  }

  Future<void> _startAnimationAndNavigate() async {
    // Fade in app name after 0.5s
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _opacity = 1.0);
    });

    // Wait for splash duration
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user is logged in
    final currentUser = FirebaseAuth.instance.currentUser;

    // Navigate accordingly
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        currentUser != null ? const HomeScreen() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF0F0F0F), const Color(0xFF1E1E1E)]
                : [const Color(0xFFFFF7F1), Colors.brown.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie animation
              Lottie.asset(
                'assets/animations/meditation.json',
                width: 240,
                height: 240,
              ),
              const SizedBox(height: 20),
              // Animated app name
              AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 2),
                child: Text(
                  "Enlightner",
                  style: GoogleFonts.merriweather(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.brown.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
