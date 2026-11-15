import 'dart:ui';

import 'package:flutter/material.dart';

/// Deep navy used for text on white surfaces.
const kInk = Color(0xFF0B1A4A);

/// Bright accent on the dark-blue background.
const kSky = Color(0xFF38BDF8);

const kGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF050816), Color(0xFF0B1F5C), Color(0xFF1546B8)],
  stops: [0, 0.55, 1],
);

/// Translucent white used by cards and tiles on the gradient.
final kGlassFill = Colors.white.withValues(alpha: 0.08);
final kGlassBorder = Colors.white.withValues(alpha: 0.16);

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
      child: Stack(
        children: [
          // Soft glow in the top-right corner for depth.
          Positioned(
            top: -120,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [kSky.withValues(alpha: 0.22), kSky.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            body: body,
            bottomNavigationBar: bottomNavigationBar,
          ),
        ],
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

/// Small heading above a group of controls.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.65),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1546B8),
    brightness: Brightness.dark,
    primary: kSky,
  );
  return ThemeData(
    colorScheme: scheme,
    textTheme: Typography.whiteMountainView,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: kInk,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.18),
        disabledForegroundColor: Colors.white70,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.07),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kSky, width: 1.5),
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF0E1B45)),
    popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF0E1B45)),
  );
}
