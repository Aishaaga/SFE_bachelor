class FeedPost {
  final String? id;
  final String type; // 'identification', 'translation_suggestion', 'plant_of_day'
  final String? userId;
  final bool isAnonymous;
  final String plantId;
  final String plantName;
  final String scientificName;
  final String? imageUrl;
  final String? identificationId;
  final String? suggestedDarija;
  final String? suggestedTamazight;
  final int upvotes;
  final int downvotes;
  final Location location;
  final int likes;
  final int commentCount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  FeedPost({
    this.id,
    required this.type,
    this.userId,
    required this.isAnonymous,
    required this.plantId,
    required this.plantName,
    required this.scientificName,
    this.imageUrl,
    this.identificationId,
    this.suggestedDarija,
    this.suggestedTamazight,
    this.upvotes = 0,
    this.downvotes = 0,
    required this.location,
    this.likes = 0,
    this.commentCount = 0,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['_id'] ?? json['id'],
      type: json['type'] ?? 'identification',
      userId: json['userId']?['_id'] ?? json['userId'],
      isAnonymous: json['isAnonymous'] ?? false,
      plantId: json['plantId']?['_id']?.toString() ?? json['plantId']?.toString() ?? '',
      plantName: json['plantName'] ?? '',
      scientificName: json['scientificName'] ?? '',
      imageUrl: json['imageUrl'],
      identificationId: json['identificationId']?['_id'] ?? json['identificationId'],
      suggestedDarija: json['suggestedDarija'],
      suggestedTamazight: json['suggestedTamazight'],
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      location: Location.fromJson(json['location'] ?? {}),
      likes: json['likes'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      user: json['userId'] != null ? User.fromJson(json['userId']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'userId': userId,
      'isAnonymous': isAnonymous,
      'plantId': plantId,
      'plantName': plantName,
      'scientificName': scientificName,
      'imageUrl': imageUrl,
      'identificationId': identificationId,
      'suggestedDarija': suggestedDarija,
      'suggestedTamazight': suggestedTamazight,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'location': location.toJson(),
      'likes': likes,
      'commentCount': commentCount,
      'status': status,
    };
  }

  FeedPost copyWith({
    String? id,
    String? type,
    String? userId,
    bool? isAnonymous,
    String? plantId,
    String? plantName,
    String? scientificName,
    String? imageUrl,
    String? identificationId,
    String? suggestedDarija,
    String? suggestedTamazight,
    int? upvotes,
    int? downvotes,
    Location? location,
    int? likes,
    int? commentCount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) {
    return FeedPost(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      scientificName: scientificName ?? this.scientificName,
      imageUrl: imageUrl ?? this.imageUrl,
      identificationId: identificationId ?? this.identificationId,
      suggestedDarija: suggestedDarija ?? this.suggestedDarija,
      suggestedTamazight: suggestedTamazight ?? this.suggestedTamazight,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      location: location ?? this.location,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}

class Location {
  final String level; // 'country', 'city', 'none'
  final String country;
  final String? city;

  Location({
    required this.level,
    this.country = 'Morocco',
    this.city,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      level: json['level'] ?? 'country',
      country: json['country'] ?? 'Morocco',
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'country': country,
      if (city != null) 'city': city,
    };
  }

  String get displayText {
    switch (level) {
      case 'city':
        return city != null ? '$city, $country' : country;
      case 'country':
        return country;
      case 'none':
        return 'Global';
      default:
        return country;
    }
  }
}

class User {
  final String? id;
  final String? email;

  User({
    this.id,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }
}
