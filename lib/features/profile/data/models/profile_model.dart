import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    required String username,
    required String email,
    String? fullName,
    String? bio,
    String? website,
    String? avatarUrl,
    int? postCount,
    int? followerCount,
    int? followingCount,
    bool? isPrivate,
    DateTime? createdAt,
    String? phoneNumber,
    String? gender,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  factory ProfileModel.empty() => ProfileModel(
        id: '',
        username: '',
        email: '',
        fullName: '',
        bio: '',
        website: '',
        avatarUrl: null,
        postCount: 0,
        followerCount: 0,
        followingCount: 0,
        isPrivate: false,
        createdAt: null,
        phoneNumber: '',
        gender: '',
      );
}

// Extension for convenience methods
extension ProfileModelExtensions on ProfileModel {
  String get displayName => fullName?.isNotEmpty == true ? fullName! : username;
  String get initials => username.isNotEmpty 
      ? username.substring(0, 1).toUpperCase()
      : '?';
  
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
}
