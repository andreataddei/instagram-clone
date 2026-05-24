import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    bool? isPrivate,
    @Default(false) bool isVerified,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int postsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isFollowing,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromSupabaseUser(
    User user, {
    Map<String, dynamic>? profile,
  }) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: profile?['username'] as String?,
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      bio: profile?['bio'] as String?,
      isPrivate: profile?['is_private'] as bool?,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
