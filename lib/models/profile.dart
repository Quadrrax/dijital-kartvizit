/// The card owner's details. Empty strings mean "not provided".
class Profile {
  final String fullName;
  final String title;
  final String company;
  final String phone;
  final String email;
  final String website;
  final String instagram;
  final String github;
  final String linkedin;
  final String x;
  final String address;
  final String? photoPath;

  const Profile({
    this.fullName = '',
    this.title = '',
    this.company = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.instagram = '',
    this.github = '',
    this.linkedin = '',
    this.x = '',
    this.address = '',
    this.photoPath,
  });

  static const empty = Profile();

  Profile copyWith({
    String? fullName,
    String? title,
    String? company,
    String? phone,
    String? email,
    String? website,
    String? instagram,
    String? github,
    String? linkedin,
    String? x,
    String? address,
    String? photoPath,
  }) {
    return Profile(
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      instagram: instagram ?? this.instagram,
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      x: x ?? this.x,
      address: address ?? this.address,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'title': title,
        'company': company,
        'phone': phone,
        'email': email,
        'website': website,
        'instagram': instagram,
        'github': github,
        'linkedin': linkedin,
        'x': x,
        'address': address,
        'photoPath': photoPath,
      };

  factory Profile.fromJson(Map<String, dynamic> json) {
    String s(String key) => json[key] as String? ?? '';
    return Profile(
      fullName: s('fullName'),
      title: s('title'),
      company: s('company'),
      phone: s('phone'),
      email: s('email'),
      website: s('website'),
      instagram: s('instagram'),
      github: s('github'),
      linkedin: s('linkedin'),
      x: s('x'),
      address: s('address'),
      photoPath: json['photoPath'] as String?,
    );
  }
}
