class Comment {
  final String? id;
  final String feedPostId;
  final String userId;
  final String content;
  final String? parentId;
  final String status;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CommentUser? user;
  final bool isAnonymous;
  final int? anonymousId;

  Comment({
    this.id,
    required this.feedPostId,
    required this.userId,
    required this.content,
    this.parentId,
    this.status = 'active',
    this.isEdited = false,
    this.editedAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.isAnonymous = false,
    this.anonymousId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      feedPostId: json['feedPostId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      parentId: json['parentId']?.toString(),
      status: json['status']?.toString() ?? 'active',
      isEdited: json['isEdited'] == true,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'].toString())
          : null,
      createdAt: DateTime.parse(
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      user: json['userId'] != null && json['userId'] is Map
          ? CommentUser.fromJson(json['userId'])
          : null,
      isAnonymous: json['isAnonymous'] == true,
      anonymousId: json['anonymousId']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedPostId': feedPostId,
      'userId': userId,
      'content': content,
      if (parentId != null) 'parentId': parentId,
      'status': status,
      'isEdited': isEdited,
      'isAnonymous': isAnonymous,
      if (anonymousId != null) 'anonymousId': anonymousId,
      if (editedAt != null) 'editedAt': editedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Comment copyWith({
    String? id,
    String? feedPostId,
    String? userId,
    String? content,
    String? parentId,
    String? status,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    CommentUser? user,
    bool? isAnonymous,
    int? anonymousId,
  }) {
    return Comment(
      id: id ?? this.id,
      feedPostId: feedPostId ?? this.feedPostId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      anonymousId: anonymousId ?? this.anonymousId,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class CommentUser {
  final String? id;
  final String? name;
  final String? email;
  final String? profileImage;

  CommentUser({
    this.id,
    this.name,
    this.email,
    this.profileImage,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
    };
  }

  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    if (email != null && email!.isNotEmpty) {
      return email!;
    }
    return 'Unknown';
  }
}
