import 'package:flutter/material.dart';

import 'data/profile_store.dart';
import 'l10n/app_localizations.dart';
import 'ui/home_screen.dart';
import 'ui/style.dart';

class KartvizitApp extends StatelessWidget {
  const KartvizitApp({super.key, required this.store});

  final ProfileStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // English first: a phone in any language other than Turkish falls back to it.
      supportedLocales: const [Locale('en'), Locale('tr')],
      home: HomeScreen(store: store),
    );
  }
}
