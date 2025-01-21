import 'package:qine_corner/core/models/user.dart';

class UserWithRole extends User {
  final String role;
  final bool isOwner;
  final DateTime joinedAt;

  const UserWithRole({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.isVerified,
    required super.profileImage,
    required super.createdAt,
    required this.role,
    required this.isOwner,
    required this.joinedAt,
  });

  factory UserWithRole.fromJson(Map<String, dynamic> json, {String? role}) {
    return UserWithRole(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'].toString(),
      email: json['email'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      profileImage: json['profile_image'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      role: role ?? json['role'] as String? ?? 'member',
      isOwner: json['is_owner'] as bool? ?? false,
      joinedAt: json['joined_at'] != null 
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
    );
  }

  factory UserWithRole.fromUser(
    User user, {
    required String role,
    bool? isOwner,
    DateTime? joinedAt,
  }) {
    return UserWithRole(
      id: user.id,
      name: user.name,
      phone: user.phone,
      email: user.email,
      isVerified: user.isVerified,
      profileImage: user.profileImage,
      createdAt: user.createdAt,
      role: role,
      isOwner: isOwner ?? false,
      joinedAt: joinedAt ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['role'] = role;
    json['is_owner'] = isOwner;
    json['joined_at'] = joinedAt.toIso8601String();
    return json;
  }

  @override
  UserWithRole copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    bool? isVerified,
    DateTime? createdAt,
    String? role,
    bool? isOwner,
    DateTime? joinedAt,
  }) {
    return UserWithRole(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      isOwner: isOwner ?? this.isOwner,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
