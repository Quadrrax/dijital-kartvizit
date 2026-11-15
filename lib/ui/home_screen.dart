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
  late List<Profile> _profiles;
  String? _activeId;
  final Set<ShareItem> _selected = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _profiles = widget.store.loadAll();
    final stored = widget.store.activeId;
    _activeId = _profiles.any((p) => p.id == stored) ? stored : _profiles.firstOrNull?.id;
    _selected.clear();
  }

  Profile? get _active => _profiles.where((p) => p.id == _activeId).firstOrNull;

  Future<void> _openEditor(Profile p) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditProfileScreen(store: widget.store, initial: p)),
    );
    if (mounted) setState(_reload);
  }

  void _newCard() {
    final l = AppLocalizations.of(context);
    final base = _active;
    // Start from the current person's details so a second card is quick to make.
    _openEditor(Profile(
      id: widget.store.newId(),
      cardName: _profiles.isEmpty ? l.defaultCardName : '',
      fullName: base?.fullName ?? '',
      phone: base?.phone ?? '',
      email: base?.email ?? '',
    ));
  }

  void _switchTo(String id) {
    widget.store.setActiveId(id);
    setState(() {
      _activeId = id;
      _selected.clear();
    });
  }

  void _share(Profile p) {
    final items = availableItems(p).where(_selected.contains).toList();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShareScreen(payload: buildPayload(p, _selected), items: items),
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
    final p = _active;
    return GradientScaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          if (p != null)
            IconButton(icon: const Icon(Icons.edit_outlined), tooltip: l.editProfile, onPressed: () => _openEditor(p)),
        ],
      ),
      body: SafeArea(child: p == null ? _empty(l) : _card(p, l)),
      bottomNavigationBar: p == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton.icon(
                  onPressed: _selected.isEmpty ? null : () => _share(p),
                  icon: const Icon(Icons.qr_code_2),
                  label: Text(l.shareCount(_selected.length)),
                ),
              ),
            ),
    );
  }

  Widget _empty(AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(shape: BoxShape.circle, color: kSky.withValues(alpha: 0.15)),
                child: const Icon(Icons.badge_outlined, size: 44, color: kSky),
              ),
              const SizedBox(height: 18),
              Text(l.emptyProfile,
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 22),
              FilledButton(onPressed: _newCard, child: Text(l.createProfile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(Profile p, AppLocalizations l) {
    final items = availableItems(p);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        _switcher(l),
        const SizedBox(height: 12),
        _header(p),
        const SizedBox(height: 8),
        SectionTitle(l.pickToShare),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [for (final item in items) _tile(item, p, l)],
        ),
      ],
    );
  }

  Widget _switcher(AppLocalizations l) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final p in _profiles)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _pill(
                text: p.cardName.isEmpty ? p.fullName : p.cardName,
                selected: p.id == _activeId,
                onTap: () => _switchTo(p.id),
              ),
            ),
          _pill(text: l.newCard, icon: Icons.add, selected: false, onTap: _newCard),
        ],
      ),
    );
  }

  Widget _pill({required String text, IconData? icon, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : kGlassFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.white : kGlassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: Colors.white), const SizedBox(width: 6)],
            Text(text,
                style: TextStyle(color: selected ? kInk : Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _header(Profile p) {
    final photo = p.photoPath;
    final hasPhoto = photo != null && File(photo).existsSync();
    final subtitle = [p.title, p.company].map((s) => s.trim()).where((s) => s.isNotEmpty).join(' · ');
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [kSky, Color(0xFF6366F1)]),
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFF0E1B45),
              backgroundImage: hasPhoto ? FileImage(File(photo)) : null,
              child: hasPhoto
                  ? null
                  : Text(_initials(p.fullName),
                      style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(ShareItem item, Profile p, AppLocalizations l) {
    final selected = _selected.contains(item);
    final fg = selected ? kInk : Colors.white;
    return GestureDetector(
      onTap: () => _toggle(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : kGlassFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.white : kGlassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? kInk.withValues(alpha: 0.08) : kSky.withValues(alpha: 0.15),
                  ),
                  child: Icon(itemIcon(item), size: 18, color: selected ? kInk : kSky),
                ),
                const Spacer(),
                Icon(selected ? Icons.check_circle : Icons.circle_outlined,
                    size: 22, color: selected ? const Color(0xFF1546B8) : Colors.white38),
              ],
            ),
            const Spacer(),
            Text(itemTitle(item, l), style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(
              itemSubtitle(item, p),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: selected ? kInk.withValues(alpha: 0.65) : Colors.white60, fontSize: 12),
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
