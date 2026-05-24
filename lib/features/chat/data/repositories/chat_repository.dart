import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:instagram_clone/core/constants/app_constants.dart';
import 'package:instagram_clone/features/chat/data/models/chat_model.dart';
import 'package:instagram_clone/features/chat/data/models/message_model.dart';

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Chats table name
  static const String _chatsTable = AppConstants.chatsTable;
  // Messages table name
  static const String _messagesTable = AppConstants.messagesTable;

  // Create a new chat
  Future<ChatModel> createChat(ChatModel chat) async {
    try {
      final response = await _supabase
          .from(_chatsTable)
          .insert(chat.toJson())
          .select()
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to create chat: ${response.error!.message}');
      }

      return ChatModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  // Get chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    try {
      final response = await _supabase
          .from(_chatsTable)
          .select()
          .eq('id', chatId)
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get chat: ${response.error!.message}');
      }

      if (response.data == null) return null;

      return ChatModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  // Get chat between two users
  Future<ChatModel?> getChatBetweenUsers(String userId1, String userId2) async {
    try {
      final response = await _supabase
          .from(_chatsTable)
          .select()
          .eq('is_group', false)
          .contains('participant_ids', [userId1, userId2])
          .single()
          .execute();

      if (response.error != null) {
        // If no chat exists, return null
        if (response.error!.code == 'PGRST116') {
          return null;
        }
        throw Exception('Failed to get chat: ${response.error!.message}');
      }

      if (response.data == null) return null;

      return ChatModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  // Get all chats for a user
  Future<List<ChatModel>> getChatsForUser(String userId) async {
    try {
      final response = await _supabase
          .from(_chatsTable)
          .select()
          .contains('participant_ids', [userId])
          .order('last_message_time', ascending: false)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get chats: ${response.error!.message}');
      }

      final chats = (response.data as List<dynamic>?)
          ?.map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return chats;
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }

  // Send a message
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      // First, send the message
      final response = await _supabase
          .from(_messagesTable)
          .insert(message.toJson())
          .select()
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to send message: ${response.error!.message}');
      }

      final sentMessage = MessageModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Update the chat's last message
      await _supabase
          .from(_chatsTable)
          .update({
            'last_message': message.content,
            'last_message_time': message.sentAt.toIso8601String(),
            'last_message_sender_id': message.senderId,
          })
          .eq('id', message.chatId)
          .execute();

      return sentMessage;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages for a chat
  Future<List<MessageModel>> getMessagesForChat(String chatId, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from(_messagesTable)
          .select()
          .eq('chat_id', chatId)
          .order('sent_at', ascending: true)
          .limit(limit)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get messages: ${response.error!.message}');
      }

      final messages = (response.data as List<dynamic>?)
          ?.map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return messages;
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      // Mark all unread messages from other users as read
      await _supabase
          .from(_messagesTable)
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('sender_id', userId)
          .eq('is_read', false)
          .execute();

      // Reset unread count for the chat
      await _supabase
          .from(_chatsTable)
          .update({'unread_count': 0})
          .eq('id', chatId)
          .execute();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId, String chatId) async {
    try {
      await _supabase
          .from(_messagesTable)
          .delete()
          .eq('id', messageId)
          .execute();

      // Update the chat's last message if needed
      final lastMessageResponse = await _supabase
          .from(_messagesTable)
          .select()
          .eq('chat_id', chatId)
          .order('sent_at', ascending: false)
          .limit(1)
          .single()
          .execute();

      if (lastMessageResponse.data != null) {
        final lastMessage = MessageModel.fromJson(
          lastMessageResponse.data as Map<String, dynamic>,
        );

        await _supabase
            .from(_chatsTable)
            .update({
              'last_message': lastMessage.content,
              'last_message_time': lastMessage.sentAt.toIso8601String(),
              'last_message_sender_id': lastMessage.senderId,
            })
            .eq('id', chatId)
            .execute();
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat
      await _supabase
          .from(_messagesTable)
          .delete()
          .eq('chat_id', chatId)
          .execute();

      // Delete the chat
      await _supabase
          .from(_chatsTable)
          .delete()
          .eq('id', chatId)
          .execute();
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  // Get unread message count for a user
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final response = await _supabase
          .from(_chatsTable)
          .select()
          .contains('participant_ids', [userId])
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get unread count: ${response.error!.message}');
      }

      final chats = (response.data as List<dynamic>?)
          ?.map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return chats.fold<int>(0, (sum, chat) => sum + (chat.unreadCount ?? 0));
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}
