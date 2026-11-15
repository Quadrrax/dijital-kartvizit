import 'package:flutter/material.dart';

import 'app.dart';
import 'data/profile_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await ProfileStore.open();
  runApp(KartvizitApp(store: store));
}
