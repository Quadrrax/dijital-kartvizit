import 'dart:ui';

import 'package:flutter/material.dart';

const kIndigo = Color(0xFF4F46E5);
const kPink = Color(0xFFDB2777);

const kGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kIndigo, kPink, Color(0xFFF59E0B)],
);

/// Translucent white used by cards and tiles on the gradient.
final kGlassFill = Colors.white.withValues(alpha: 0.18);
final kGlassBorder = Colors.white.withValues(alpha: 0.30);

/// A Scaffold drawn over the app's gradient.
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key, this.appBar, this.body, this.bottomNavigationBar});

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: kGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}

/// Frosted-glass card: blurred backdrop, translucent fill, thin white border.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: kGlassFill,
            borderRadius: radius,
            border: Border.all(color: kGlassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: kIndigo, brightness: Brightness.dark);
  return ThemeData(
    colorScheme: scheme,
    textTheme: Typography.whiteMountainView,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: kIndigo,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.35),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.12),
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
