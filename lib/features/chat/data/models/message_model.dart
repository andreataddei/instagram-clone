import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
  voice,
  system,
}

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String chatId,
    required String senderId,
    required String content,
    required DateTime sentAt,
    required bool isRead,
    MessageType? type,
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    Map<String, dynamic>? metadata,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  factory MessageModel.empty() => MessageModel(
        id: '',
        chatId: '',
        senderId: '',
        content: '',
        sentAt: DateTime.now(),
        isRead: false,
        type: MessageType.text,
        imageUrl: null,
        videoUrl: null,
        audioUrl: null,
        metadata: null,
      );
}

// Extension for convenience methods
extension MessageModelExtensions on MessageModel {
  bool get isFromCurrentUser => senderId == 'current_user_id'; // TODO: Replace with actual user ID
  bool get isText => type == MessageType.text || type == null;
  bool get isImage => type == MessageType.image && imageUrl != null;
  bool get isVideo => type == MessageType.video && videoUrl != null;
  bool get isAudio => type == MessageType.audio || type == MessageType.voice;
  bool get isSystem => type == MessageType.system;

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(sentAt);
    
    if (difference.inDays == 0) {
      return '${sentAt.hour}:${sentAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return _getDayName(sentAt.weekday);
    } else {
      return '${sentAt.day}/
${sentAt.month}';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
