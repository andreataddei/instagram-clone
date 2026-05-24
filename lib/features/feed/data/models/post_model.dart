import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    required String id,
    required String userId,
    required String username,
    required String? userAvatar,
    required String caption,
    required List<String> imageUrls,
    required List<String> likes,
    required List<String> comments,
    required DateTime createdAt,
    required String location,
    required List<String> hashtags,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  factory PostModel.empty() => PostModel(
        id: '',
        userId: '',
        username: '',
        userAvatar: null,
        caption: '',
        imageUrls: [],
        likes: [],
        comments: [],
        createdAt: DateTime.now(),
        location: '',
        hashtags: [],
      );
}

// Extension for convenience methods
extension PostModelExtensions on PostModel {
  bool get isLikedByCurrentUser => likes.isNotEmpty;
  int get likeCount => likes.length;
  int get commentCount => comments.length;
  bool get hasMultipleImages => imageUrls.length > 1;
  String get firstImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  PostModel copyWithLikeToggle(String userId) {
    final newLikes = likes.contains(userId)
        ? likes.where((id) => id != userId).toList()
        : [...likes, userId];
    return copyWith(likes: newLikes);
  }
}
