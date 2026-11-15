import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

/// Keeps the cards on the phone: JSON list in shared_preferences, photos as
/// files in the app's documents directory.
class ProfileStore {
  ProfileStore(this._prefs, this._photoDir);

  static const _key = 'profiles';
  static const _legacyKey = 'profile';
  static const _activeKey = 'activeProfile';

  final SharedPreferences _prefs;
  final Directory _photoDir;
  int _idCounter = 0;

  static Future<ProfileStore> open() async {
    return ProfileStore(
      await SharedPreferences.getInstance(),
      await getApplicationDocumentsDirectory(),
    );
  }

  String newId() => '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  List<Profile> loadAll() {
    try {
      final raw = _prefs.getString(_key);
      if (raw != null) {
        return [
          for (final p in jsonDecode(raw) as List) Profile.fromJson(p as Map<String, dynamic>),
        ];
      }
      final legacy = _prefs.getString(_legacyKey);
      if (legacy != null) {
        return [Profile.fromJson(jsonDecode(legacy) as Map<String, dynamic>).copyWith(id: newId())];
      }
    } on FormatException {
      // fall through
    } on TypeError {
      // fall through
    }
    return [];
  }

  Future<void> saveAll(List<Profile> profiles) =>
      _prefs.setString(_key, jsonEncode([for (final p in profiles) p.toJson()]));

  String? get activeId => _prefs.getString(_activeKey);

  Future<void> setActiveId(String id) => _prefs.setString(_activeKey, id);

  /// Copies the picked image into the app's own directory under a fresh name
  /// (so Flutter's image cache never shows the old photo) and removes this
  /// profile's earlier copies.
  Future<String> importPhoto(String sourcePath, String profileId) async {
    final prefix = 'profile_${profileId}_';
    final dot = sourcePath.lastIndexOf('.');
    final ext = dot > sourcePath.lastIndexOf('/') ? sourcePath.substring(dot) : '';
    final name = '$prefix${DateTime.now().millisecondsSinceEpoch}$ext';
    final copy = await File(sourcePath).copy('${_photoDir.path}/$name');
    for (final f in _photoDir.listSync().whereType<File>()) {
      final base = f.uri.pathSegments.last;
      if (base.startsWith(prefix) && base != name) f.deleteSync();
    }
    return copy.path;
  }

  /// Removes every photo file belonging to [profileId].
  void deletePhotos(String profileId) {
    for (final f in _photoDir.listSync().whereType<File>()) {
      if (f.uri.pathSegments.last.startsWith('profile_${profileId}_')) f.deleteSync();
    }
  }
}
