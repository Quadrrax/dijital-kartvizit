import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/profile_store.dart';
import '../l10n/app_localizations.dart';
import '../models/profile.dart';
import 'style.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.store, required this.initial});

  final ProfileStore store;
  final Profile initial;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c = {
    for (final MapEntry(:key, :value) in widget.initial.toJson().entries)
      if (key != 'photoPath') key: TextEditingController(text: value as String),
  };
  late String? _photoPath = widget.initial.photoPath;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
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
    final path = await widget.store.importPhoto(picked.path);
    // importPhoto removed the previous file, so persist the new path right
    // away; otherwise backing out without saving would leave a dead path.
    await widget.store.save(widget.store.load().copyWith(photoPath: path));
    if (!mounted) return;
    setState(() => _photoPath = path);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    String v(String key) => _c[key]!.text.trim();
    final p = Profile(
      fullName: v('fullName'),
      title: v('title'),
      company: v('company'),
      phone: v('phone'),
      email: v('email'),
      website: v('website'),
      instagram: v('instagram'),
      github: v('github'),
      linkedin: v('linkedin'),
      x: v('x'),
      address: v('address'),
      photoPath: _photoPath,
    );
    await widget.store.save(p);
    if (mounted) Navigator.of(context).pop(p);
  }

  Widget _field(
    String key,
    String label, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
    bool handle = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: Key('field_$key'),
        controller: _c[key],
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboard,
        validator: validator,
        autocorrect: !handle,
        textCapitalization: key == 'fullName' ? TextCapitalization.words : TextCapitalization.none,
        minLines: 1,
        maxLines: keyboard == TextInputType.multiline ? 3 : 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final photo = _photoPath;
    final hasPhoto = photo != null && File(photo).existsSync();
    return GradientScaffold(
      appBar: AppBar(title: Text(l.editProfile)),
      body: SafeArea(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    backgroundImage: hasPhoto ? FileImage(File(photo)) : null,
                    child: hasPhoto ? null : const Icon(Icons.add_a_photo, color: Colors.white, size: 32),
                  ),
                ),
                TextButton(
                  onPressed: _pickPhoto,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Text(l.changePhoto),
                ),
                const SizedBox(height: 8),
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
                      _field('email', l.fieldEmail, keyboard: TextInputType.emailAddress, handle: true),
                      _field('website', l.fieldWebsite, keyboard: TextInputType.url, handle: true),
                      _field('instagram', l.fieldInstagram, handle: true),
                      _field('github', l.fieldGithub, handle: true),
                      _field('linkedin', l.fieldLinkedin, handle: true),
                      _field('x', l.fieldX, handle: true),
                      _field('address', l.fieldAddress, keyboard: TextInputType.multiline),
                    ],
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
