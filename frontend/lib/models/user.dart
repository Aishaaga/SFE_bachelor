class User {
  final String id;
  final String email;
  final String username;
  final String role;
  final String name;
  final String bio;
  final String location;
  final String profileImage;
  final int contributionsCount;
  final int identificationsCount;
  final int translationSuggestionsCount;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    this.name = '',
    this.bio = '',
    this.location = '',
    this.profileImage = '',
    this.contributionsCount = 0,
    this.identificationsCount = 0,
    this.translationSuggestionsCount = 0,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'] ?? json['email']?.split('@')[0] ?? '',
      role: json['role'],
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      profileImage: json['profileImage'] ?? '',
      contributionsCount: json['contributionsCount'] ?? 0,
      identificationsCount: json['identificationsCount'] ?? 0,
      translationSuggestionsCount: json['translationSuggestionsCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
