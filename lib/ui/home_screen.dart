import 'dart:io';

import 'package:flutter/material.dart';

import '../data/profile_store.dart';
import '../l10n/app_localizations.dart';
import '../models/profile.dart';
import '../sharing/payload.dart';
import '../sharing/share_item.dart';
import 'edit_profile_screen.dart';
import 'item_visuals.dart';
import 'share_screen.dart';
import 'style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});

  final ProfileStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Profile _profile = widget.store.load();
  final Set<ShareItem> _selected = {};

  Future<void> _edit() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditProfileScreen(store: widget.store, initial: _profile),
      ),
    );
    if (!mounted) return;
    setState(() {
      _profile = widget.store.load();
      _selected.retainAll(availableItems(_profile));
    });
  }

  void _share() {
    final items = ShareItem.values.where(_selected.contains).toList();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShareScreen(payload: buildPayload(_profile, _selected), items: items),
      ),
    );
  }

  void _toggle(ShareItem item) {
    setState(() {
      if (!_selected.remove(item)) _selected.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasProfile = _profile.fullName.trim().isNotEmpty;
    return GradientScaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(icon: const Icon(Icons.edit), tooltip: l.editProfile, onPressed: _edit),
        ],
      ),
      body: SafeArea(child: hasProfile ? _card(l) : _empty(l)),
      bottomNavigationBar: hasProfile
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: _selected.isEmpty ? null : _share,
                  child: Text(l.shareCount(_selected.length)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _empty(AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.badge_outlined, size: 56, color: Colors.white),
              const SizedBox(height: 16),
              Text(l.emptyProfile, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              FilledButton(onPressed: _edit, child: Text(l.createProfile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(AppLocalizations l) {
    final items = availableItems(_profile);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [for (final item in items) _tile(item, l)],
        ),
      ],
    );
  }

  Widget _header() {
    final p = _profile;
    final photo = p.photoPath;
    final hasPhoto = photo != null && File(photo).existsSync();
    final subtitle = [p.title, p.company].map((s) => s.trim()).where((s) => s.isNotEmpty).join(' · ');
    return GlassCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            backgroundImage: hasPhoto ? FileImage(File(photo)) : null,
            child: hasPhoto
                ? null
                : Text(_initials(p.fullName),
                    style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Text(p.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          ],
        ],
      ),
    );
  }

  Widget _tile(ShareItem item, AppLocalizations l) {
    final selected = _selected.contains(item);
    final fg = selected ? kIndigo : Colors.white;
    return GestureDetector(
      onTap: () => _toggle(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? Colors.white : kGlassFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGlassBorder),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(itemIcon(item), color: fg, size: 28),
                  const SizedBox(height: 8),
                  Text(itemLabel(item, l), style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (selected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: kPink, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final first = words.first.characters.first;
    final last = words.length > 1 ? words.last.characters.first : '';
    return (first + last).toUpperCase();
  }
}
