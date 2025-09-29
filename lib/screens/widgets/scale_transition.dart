import 'package:flutter/material.dart';

import '../game_screen.dart';
import '../welcome_screen.dart';

// Custom Scale Transition Route
class ScaleTransitionRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;

  ScaleTransitionRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Scale animation for the incoming page
      var scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      ));

      // Fade animation for smooth opacity change
      var fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Interval(0.0, 0.7, curve: curve),
      ));

      // Scale out animation for the outgoing page
      var scaleOutAnimation = Tween<double>(
        begin: 1.0,
        end: 1.1,
      ).animate(CurvedAnimation(
        parent: secondaryAnimation,
        curve: curve,
      ));

      // Fade out animation for the outgoing page
      var fadeOutAnimation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: secondaryAnimation,
        curve: Interval(0.3, 1.0, curve: curve),
      ));

      return Stack(
        children: [
          // Outgoing page (scales up and fades out)
          if (secondaryAnimation.status != AnimationStatus.dismissed)
            ScaleTransition(
              scale: scaleOutAnimation,
              child: FadeTransition(
                opacity: fadeOutAnimation,
                child: Container(), // This will be the previous page
              ),
            ),
          // Incoming page (scales in and fades in)
          ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        ],
      );
    },
  );
}

// Alternative: Simpler Scale Transition (recommended for your app)
class SimpleScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SimpleScaleRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 350),
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Scale and fade animation
      var scaleAnimation = Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack, // This gives a nice bounce effect
      ));

      var fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ));

      return ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

// Extension to make navigation easier
extension NavigationExtensions on BuildContext {
  // Method to navigate with scale transition
  Future<T?> pushWithScaleTransition<T>(Widget page) {
    return Navigator.of(this).push<T>(
      SimpleScaleRoute(child: page),
    );
  }

  // Method to replace current route with scale transition
  Future<T?> pushReplacementWithScaleTransition<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, dynamic>(
      SimpleScaleRoute(child: page),
    );
  }
}

// Usage Examples:

// Example 1: Navigate to Game Screen
void navigateToGameScreen(BuildContext context, String difficulty) {
  context.pushWithScaleTransition(
    GameScreen(difficulty: difficulty),
  );
}

// Example 2: Navigate back to Welcome Screen
void navigateToWelcomeScreen(BuildContext context) {
  context.pushReplacementWithScaleTransition(
    const WelcomeScreen(),
  );
}

// Example 3: Traditional Navigator usage (if you prefer)
void navigateWithTraditionalMethod(BuildContext context, Widget targetScreen) {
  Navigator.of(context).push(
    SimpleScaleRoute(child: targetScreen),
  );
}