import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/profile_store.dart';
import '../l10n/app_localizations.dart';
import '../models/profile.dart';
import 'item_visuals.dart';
import 'style.dart';

/// Edits one card ([initial]); saving inserts or replaces it in the store and
/// makes it the active card.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.store, required this.initial});

  final ProfileStore store;
  final Profile initial;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _AccountRow {
  _AccountRow(this.type, String value, String label)
      : value = TextEditingController(text: value),
        label = TextEditingController(text: label),
        uid = _next++;

  static int _next = 0;
  final int uid;
  final AccountType type;
  final TextEditingController value;
  final TextEditingController label;

  void dispose() {
    value.dispose();
    label.dispose();
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final Profile _p = widget.initial;
  late final _cardName = TextEditingController(text: _p.cardName);
  late final _fields = {
    'fullName': TextEditingController(text: _p.fullName),
    'title': TextEditingController(text: _p.title),
    'company': TextEditingController(text: _p.company),
    'phone': TextEditingController(text: _p.phone),
    'email': TextEditingController(text: _p.email),
    'address': TextEditingController(text: _p.address),
  };
  late final List<_AccountRow> _accounts = [
    for (final a in _p.accounts) _AccountRow(a.type, a.value, a.label),
  ];
  late String? _photoPath = _p.photoPath;

  bool get _isNew => !widget.store.loadAll().any((x) => x.id == _p.id);

  @override
  void dispose() {
    _cardName.dispose();
    for (final c in _fields.values) {
      c.dispose();
    }
    for (final r in _accounts) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    final path = await widget.store.importPhoto(picked.path, _p.id);
    // importPhoto removed this card's previous file, so if the card is already
    // saved, point it at the new one right away (backing out must not leave a
    // dead path behind).
    final all = widget.store.loadAll();
    final i = all.indexWhere((x) => x.id == _p.id);
    if (i >= 0) {
      all[i] = all[i].copyWith(photoPath: path);
      await widget.store.saveAll(all);
    }
    if (!mounted) return;
    setState(() => _photoPath = path);
  }

  Future<void> _addAccount(AccountType type) async {
    setState(() => _accounts.add(_AccountRow(type, '', '')));
  }

  void _removeAccount(_AccountRow row) {
    setState(() => _accounts.remove(row));
    row.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    String v(String key) => _fields[key]!.text.trim();
    final cardName = _cardName.text.trim();
    final saved = Profile(
      id: _p.id,
      cardName: cardName.isEmpty ? l.defaultCardName : cardName,
      fullName: v('fullName'),
      title: v('title'),
      company: v('company'),
      phone: v('phone'),
      email: v('email'),
      address: v('address'),
      photoPath: _photoPath,
      accounts: [
        for (final r in _accounts)
          if (r.value.text.trim().isNotEmpty)
            Account(type: r.type, value: r.value.text.trim(), label: r.label.text.trim()),
      ],
    );
    final all = widget.store.loadAll();
    final i = all.indexWhere((x) => x.id == saved.id);
    if (i >= 0) {
      all[i] = saved;
    } else {
      all.add(saved);
    }
    await widget.store.saveAll(all);
    await widget.store.setActiveId(saved.id);
    if (mounted) Navigator.of(context).pop(saved);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteCard),
        content: Text(l.deleteCardConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true) return;
    final rest = widget.store.loadAll().where((x) => x.id != _p.id).toList();
    await widget.store.saveAll(rest);
    if (rest.isNotEmpty) await widget.store.setActiveId(rest.first.id);
    widget.store.deletePhotos(_p.id);
    if (mounted) Navigator.of(context).pop();
  }

  Widget _field(
    String key,
    String label, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
    TextEditingController? controller,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: Key('field_$key'),
        controller: controller ?? _fields[key],
        decoration: InputDecoration(labelText: label, hintText: hint),
        keyboardType: keyboard,
        validator: validator,
        textCapitalization: key == 'fullName' || key == 'cardName'
            ? TextCapitalization.words
            : TextCapitalization.none,
        minLines: 1,
        maxLines: keyboard == TextInputType.multiline ? 3 : 1,
      ),
    );
  }

  String _valueLabel(AccountType t, AppLocalizations l) => switch (t) {
        AccountType.whatsapp => l.valuePhone,
        AccountType.website => l.valueUrl,
        _ => l.valueUsername,
      };

  Widget _accountCard(int i, _AccountRow row, AppLocalizations l) {
    return Container(
      key: ValueKey(row.uid),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 2),
      decoration: BoxDecoration(
        color: kGlassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kGlassBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(accountIcon(row.type), color: kSky, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(accountTypeName(row.type, l),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              IconButton(
                key: Key('acc_remove_$i'),
                tooltip: l.removeAccount,
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => _removeAccount(row),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                _field('acc_value_$i', _valueLabel(row.type, l),
                    controller: row.value,
                    keyboard: switch (row.type) {
                      AccountType.whatsapp => TextInputType.phone,
                      AccountType.website => TextInputType.url,
                      _ => TextInputType.text,
                    }),
                _field('acc_label_$i', l.accountLabel, controller: row.label),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final photo = _photoPath;
    final hasPhoto = photo != null && File(photo).existsSync();
    return GradientScaffold(
      appBar: AppBar(
        title: Text(_isNew ? l.newCard : l.editProfile),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: l.deleteCard,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [kSky, Color(0xFF6366F1)]),
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: const Color(0xFF0E1B45),
                        backgroundImage: hasPhoto ? FileImage(File(photo)) : null,
                        child: hasPhoto ? null : const Icon(Icons.add_a_photo, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _pickPhoto,
                    style: TextButton.styleFrom(foregroundColor: kSky),
                    child: Text(l.changePhoto),
                  ),
                ),
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: _field('cardName', l.cardName, controller: _cardName, hint: l.cardNameHint),
                ),
                SectionTitle(l.contactDetails),
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Column(
                    children: [
                      _field('fullName', l.fieldFullName,
                          keyboard: TextInputType.name,
                          validator: (s) => (s ?? '').trim().isEmpty ? l.requiredField : null),
                      _field('title', l.fieldTitle),
                      _field('company', l.fieldCompany),
                      _field('phone', l.fieldPhone, keyboard: TextInputType.phone),
                      _field('email', l.fieldEmail, keyboard: TextInputType.emailAddress),
                      _field('address', l.fieldAddress, keyboard: TextInputType.multiline),
                    ],
                  ),
                ),
                SectionTitle(l.accounts),
                if (_accounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                    child: Text(l.noAccounts, style: const TextStyle(color: Colors.white60)),
                  ),
                for (final (i, row) in _accounts.indexed) _accountCard(i, row, l),
                PopupMenuButton<AccountType>(
                  onSelected: _addAccount,
                  itemBuilder: (context) => [
                    for (final t in AccountType.values)
                      PopupMenuItem(
                        value: t,
                        child: Row(
                          children: [
                            Icon(accountIcon(t), size: 18, color: kSky),
                            const SizedBox(width: 12),
                            Text(accountTypeName(t, l), style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                  ],
                  child: IgnorePointer(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: Text(l.addAccount),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(onPressed: _save, child: Text(l.save)),
        ),
      ),
    );
  }
}
