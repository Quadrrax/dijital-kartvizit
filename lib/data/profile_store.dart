import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

/// Keeps the profile on the phone: JSON in shared_preferences, photo as a
/// file in the app's documents directory.
class ProfileStore {
  ProfileStore(this._prefs, this._photoDir);

  static const _key = 'profile';
  static const _photoPrefix = 'profile_';

  final SharedPreferences _prefs;
  final Directory _photoDir;

  static Future<ProfileStore> open() async {
    return ProfileStore(
      await SharedPreferences.getInstance(),
      await getApplicationDocumentsDirectory(),
    );
  }

  Profile load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return Profile.empty;
    try {
      return Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return Profile.empty;
    } on TypeError {
      return Profile.empty;
    }
  }

  Future<void> save(Profile p) => _prefs.setString(_key, jsonEncode(p.toJson()));

  /// Copies the picked image into the app's own directory under a fresh
  /// name (so Flutter's image cache never shows the old photo) and removes
  /// earlier copies.
  Future<String> importPhoto(String sourcePath) async {
    final dot = sourcePath.lastIndexOf('.');
    final ext = dot > sourcePath.lastIndexOf('/') ? sourcePath.substring(dot) : '';
    final name = '$_photoPrefix${DateTime.now().millisecondsSinceEpoch}$ext';
    final copy = await File(sourcePath).copy('${_photoDir.path}/$name');
    for (final f in _photoDir.listSync().whereType<File>()) {
      final base = f.uri.pathSegments.last;
      if (base.startsWith(_photoPrefix) && base != name) f.deleteSync();
    }
    return copy.path;
  }
}
