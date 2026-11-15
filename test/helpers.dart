import 'dart:convert';
import 'dart:io';

import 'package:dijital_kartvizit/data/profile_store.dart';
import 'package:dijital_kartvizit/l10n/app_localizations.dart';
import 'package:dijital_kartvizit/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps [child] in a Turkish MaterialApp (flutter test defaults to en_US).
Widget wrapTr(Widget child) => MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

/// A store backed by mock prefs and a fresh temp directory, optionally
/// pre-filled with [p].
Future<ProfileStore> testStore([Profile? p]) async {
  SharedPreferences.setMockInitialValues(
      p == null ? {} : {'profile': jsonEncode(p.toJson())});
  final dir = Directory.systemTemp.createTempSync('kartvizit_test');
  return ProfileStore(await SharedPreferences.getInstance(), dir);
}
