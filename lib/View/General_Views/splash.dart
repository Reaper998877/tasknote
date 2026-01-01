import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tasknote/Controller/c_group.dart';
import 'package:tasknote/Controller/c_note.dart';
import 'package:tasknote/General/common_functions.dart';

final NoteController noteController = NoteController();
final GroupNotesController groupController = GroupNotesController();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Define animation duration constants for synchronization
  static const Duration _totalDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for the total duration of the splash experience
    await Future.delayed(_totalDuration);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handling width safely if CommonFunctions is generic, otherwise use MediaQuery
    final double logoSize = CommonFunctions.getWidth(context, 0.45);

    // New Modern Gradient Colors
    const colors = [
      Color(0xFF54acbf),
      Color(0xFF26658c),
      Color(0xFF023859), // Vibrant Violet
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background Decorative Elements (Subtle Glows)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ).animate().scale(duration: 2000.ms, curve: Curves.easeInOut),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. The Logo
                  _buildLogo(logoSize),

                  const SizedBox(height: 40),

                  // 2. The App Name
                  const Text(
                        'TaskNote',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'average',
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 4),
                              blurRadius: 15.0,
                              color: Color.fromRGBO(0, 0, 0, 0.2),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 500.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .blurXY(
                        begin: 10,
                        end: 0,
                        duration: 600.ms,
                      ), // Cinematic unblur

                  const SizedBox(height: 12),

                  // 3. The Slogan
                  const Text(
                        'Plan smarter. Act faster.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'average',
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: 600.ms,
                        delay: 900.ms,
                      ) // Staggered delay
                      .slideY(begin: 0.2, end: 0, duration: 600.ms),
                ],
              ),
            ),

            // Optional: Loading Indicator at bottom
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ).animate().fadeIn(delay: 1500.ms),
            ),

            // Background Decorative Elements (Subtle Glows)
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ).animate().scale(duration: 2000.ms, curve: Curves.easeInOut),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 255, 255, 255),
                blurRadius: 30,
                spreadRadius: 0,
                blurStyle: BlurStyle.outer,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          padding: const EdgeInsets.all(
            25.0,
          ), // Padding inside the white circle
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  blurRadius: 35,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Image.asset(
              'assets/icon/splashLogo.png', // Replaced variable with string for copy-paste safety
              fit: BoxFit.contain,
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        // Entrance Animation
        .scale(
          duration: 800.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0.5, 0.5),
        )
        .fade(duration: 500.ms)
        .shimmer(
          delay: 1000.ms,
          duration: 1500.ms,
          color: Colors.grey.withValues(alpha: 0.2),
        )
        // Continuous Floating Animation (Breathing) after entrance
        .then()
        .moveY(begin: 0, end: -10, duration: 2000.ms, curve: Curves.easeInOut);
  }
}
