/// Platforms a card can link to. Declaration order = order in "add account".
enum AccountType { whatsapp, instagram, github, linkedin, x, website }

/// One account on one platform. A profile may hold several of the same type.
class Account {
  const Account({required this.type, this.value = '', this.label = ''});

  final AccountType type;

  /// Username, phone number (WhatsApp) or URL (website).
  final String value;

  /// Optional user label such as "İş" to tell same-platform accounts apart.
  final String label;

  Account copyWith({AccountType? type, String? value, String? label}) => Account(
        type: type ?? this.type,
        value: value ?? this.value,
        label: label ?? this.label,
      );

  Map<String, dynamic> toJson() => {'type': type.name, 'value': value, 'label': label};

  /// Null for an unknown type (e.g. written by a newer app version).
  static Account? fromJson(Map<String, dynamic> json) {
    final type = AccountType.values.asNameMap()[json['type']];
    if (type == null) return null;
    return Account(
      type: type,
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

/// One business card. Empty strings mean "not provided".
class Profile {
  const Profile({
    this.id = '',
    this.cardName = '',
    this.fullName = '',
    this.title = '',
    this.company = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.photoPath,
    this.accounts = const [],
  });

  final String id;

  /// Name of the card itself, e.g. "Kişisel" or "İş".
  final String cardName;
  final String fullName;
  final String title;
  final String company;
  final String phone;
  final String email;
  final String address;
  final String? photoPath;
  final List<Account> accounts;

  static const empty = Profile();

  Profile copyWith({
    String? id,
    String? cardName,
    String? fullName,
    String? title,
    String? company,
    String? phone,
    String? email,
    String? address,
    String? photoPath,
    List<Account>? accounts,
  }) {
    return Profile(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      photoPath: photoPath ?? this.photoPath,
      accounts: accounts ?? this.accounts,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardName': cardName,
        'fullName': fullName,
        'title': title,
        'company': company,
        'phone': phone,
        'email': email,
        'address': address,
        'photoPath': photoPath,
        'accounts': [for (final a in accounts) a.toJson()],
      };

  factory Profile.fromJson(Map<String, dynamic> json) {
    String s(String key) => json[key] as String? ?? '';
    final raw = json['accounts'];
    final accounts = raw is List
        ? [
            for (final a in raw.whereType<Map<String, dynamic>>()) ?Account.fromJson(a),
          ]
        : _migrateFlatAccounts(json);
    return Profile(
      id: s('id'),
      cardName: s('cardName'),
      fullName: s('fullName'),
      title: s('title'),
      company: s('company'),
      phone: s('phone'),
      email: s('email'),
      address: s('address'),
      photoPath: json['photoPath'] as String?,
      accounts: accounts,
    );
  }

  /// First app version stored one field per platform; WhatsApp used the phone.
  static List<Account> _migrateFlatAccounts(Map<String, dynamic> json) {
    String s(String key) => (json[key] as String? ?? '').trim();
    return [
      for (final (type, key) in [
        (AccountType.whatsapp, 'phone'),
        (AccountType.instagram, 'instagram'),
        (AccountType.github, 'github'),
        (AccountType.linkedin, 'linkedin'),
        (AccountType.x, 'x'),
        (AccountType.website, 'website'),
      ])
        if (s(key).isNotEmpty) Account(type: type, value: s(key)),
    ];
  }
}
