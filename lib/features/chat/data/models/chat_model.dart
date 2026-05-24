import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
class ChatModel with _$ChatModel {
  const factory ChatModel({
    required String id,
    required List<String> participantIds,
    required String lastMessage,
    required DateTime lastMessageTime,
    required String lastMessageSenderId,
    required bool isGroup,
    String? groupName,
    String? groupAvatar,
    List<String>? groupAdmins,
    int? unreadCount,
    bool? isMuted,
    DateTime? createdAt,
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  factory ChatModel.empty() => ChatModel(
        id: '',
        participantIds: [],
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
        isGroup: false,
        groupName: null,
        groupAvatar: null,
        groupAdmins: null,
        unreadCount: 0,
        isMuted: false,
        createdAt: null,
      );
}

// Extension for convenience methods
extension ChatModelExtensions on ChatModel {
  String get chatName => isGroup ? (groupName ?? 'Group Chat') : _getOtherParticipant();
  String get chatAvatar => isGroup 
      ? (groupAvatar ?? '')
      : _getOtherParticipantAvatar();
  
  String _getOtherParticipant() {
    // TODO: Get from auth state
    final currentUserId = 'current_user_id';
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => 'Unknown',
    );
  }

  String _getOtherParticipantAvatar() {
    // TODO: Implement logic to get other participant's avatar
    return '';
  }

  bool get hasUnreadMessages => unreadCount != null && unreadCount! > 0;
  DateTime get lastMessageDate => lastMessageTime;

  String get formattedLastMessageTime {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);
    
    if (difference.inDays == 0) {
      return '${lastMessageTime.hour}:${lastMessageTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return _getDayName(lastMessageTime.weekday);
    } else {
      return '${lastMessageTime.day}/
${lastMessageTime.month}/
${lastMessageTime.year}';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
