import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_model.freezed.dart';
part 'story_model.g.dart';

@freezed
class StoryModel with _$StoryModel {
  const factory StoryModel({
    required String id,
    required String userId,
    required String username,
    required String? userAvatar,
    required String imageUrl,
    required String? videoUrl,
    required DateTime createdAt,
    required DateTime expiresAt,
    required List<String> viewers,
    bool isVideo,
    String? caption,
    String? location,
    List<String>? hashtags,
    String? backgroundColor,
    String? textColor,
    String? fontStyle,
  }) = _StoryModel;

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);

  factory StoryModel.empty() => StoryModel(
        id: '',
        userId: '',
        username: '',
        userAvatar: null,
        imageUrl: '',
        videoUrl: null,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        viewers: [],
        isVideo: false,
        caption: null,
        location: null,
        hashtags: null,
        backgroundColor: null,
        textColor: null,
        fontStyle: null,
      );
}

// Extension for convenience methods
extension StoryModelExtensions on StoryModel {
  bool get hasExpired => DateTime.now().isAfter(expiresAt);
  bool get isViewed => viewers.isNotEmpty;
  int get viewerCount => viewers.length;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  
  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get formattedTimeRemaining {
    final remaining = timeRemaining;
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m';
    } else {
      return '${remaining.inSeconds}s';
    }
  }
}
