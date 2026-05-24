import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/features/chat/data/models/chat_model.dart';
import 'package:instagram_clone/features/chat/data/models/message_model.dart';
import 'package:instagram_clone/features/chat/data/repositories/chat_repository.dart';

// Chat Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(),
);

// Chat State
class ChatState {
  final bool isLoading;
  final List<ChatModel> chats;
  final String? error;

  const ChatState({
    this.isLoading = false,
    this.chats = const [],
    this.error,
  });

  ChatState copyWith({
    bool? isLoading,
    List<ChatModel>? chats,
    String? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      chats: chats ?? this.chats,
      error: error,
    );
  }
}

// Chats Notifier
class ChatsNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final String _currentUserId; // TODO: Get from auth state

  ChatsNotifier(this._chatRepository, this._currentUserId) 
      : super(const ChatState());

  Future<void> loadChats({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null);
    } else if (state.isLoading) {
      return;
    }

    try {
      final chats = await _chatRepository.getChatsForUser(_currentUserId);
      state = state.copyWith(
        chats: chats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createChat(ChatModel chat) async {
    try {
      final createdChat = await _chatRepository.createChat(chat);
      state = state.copyWith(
        chats: [createdChat, ...state.chats],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _chatRepository.deleteChat(chatId);
      state = state.copyWith(
        chats: state.chats.where((chat) => chat.id != chatId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    try {
      await _chatRepository.markMessagesAsRead(chatId, _currentUserId);
      state = state.copyWith(
        chats: state.chats.map((chat) {
          if (chat.id == chatId) {
            return chat.copyWith(unreadCount: 0);
          }
          return chat;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Chats Provider
final chatsProvider = StateNotifierProvider<ChatsNotifier, ChatState>(
  (ref) {
    // TODO: Get current user ID from auth state
    final currentUserId = 'current_user_id'; // Replace with actual user ID
    return ChatsNotifier(
      ref.read(chatRepositoryProvider),
      currentUserId,
    );
  },
);

// Single Chat Provider
final chatProvider = FutureProvider.family<ChatModel?, String>(
  (ref, chatId) async {
    final repository = ref.read(chatRepositoryProvider);
    return repository.getChatById(chatId);
  },
);

// Messages State
class MessagesState {
  final bool isLoading;
  final List<MessageModel> messages;
  final String? error;
  final bool hasReachedMax;

  const MessagesState({
    this.isLoading = false,
    this.messages = const [],
    this.error,
    this.hasReachedMax = false,
  });

  MessagesState copyWith({
    bool? isLoading,
    List<MessageModel>? messages,
    String? error,
    bool? hasReachedMax,
  }) {
    return MessagesState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

// Messages Notifier
class MessagesNotifier extends StateNotifier<MessagesState> {
  final ChatRepository _chatRepository;
  final String _chatId;
  final String _currentUserId; // TODO: Get from auth state
  int _page = 0;
  static const int _pageSize = 50;

  MessagesNotifier(this._chatRepository, this._chatId, this._currentUserId) 
      : super(const MessagesState());

  Future<void> loadMessages({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      state = state.copyWith(
        isLoading: true,
        error: null,
        hasReachedMax: false,
      );
    } else if (state.hasReachedMax || state.isLoading) {
      return;
    }

    try {
      final messages = await _chatRepository.getMessagesForChat(
        _chatId,
        limit: _pageSize,
      );

      if (refresh) {
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          hasReachedMax: messages.length < _pageSize,
        );
      } else {
        state = state.copyWith(
          messages: [...state.messages, ...messages],
          isLoading: false,
          hasReachedMax: messages.length < _pageSize,
        );
      }
      _page++;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      final sentMessage = await _chatRepository.sendMessage(message);
      state = state.copyWith(
        messages: [...state.messages, sentMessage],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatRepository.deleteMessage(messageId, _chatId);
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != messageId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markMessagesAsRead() async {
    try {
      await _chatRepository.markMessagesAsRead(_chatId, _currentUserId);
      state = state.copyWith(
        messages: state.messages.map((message) {
          if (!message.isFromCurrentUser && !message.isRead) {
            return message.copyWith(isRead: true);
          }
          return message;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Messages Provider
final messagesProvider = StateNotifierProvider.family<
    MessagesNotifier, MessagesState, String>(
  (ref, chatId) {
    // TODO: Get current user ID from auth state
    final currentUserId = 'current_user_id'; // Replace with actual user ID
    return MessagesNotifier(
      ref.read(chatRepositoryProvider),
      chatId,
      currentUserId,
    );
  },
);

// Unread Message Count Provider
final unreadMessageCountProvider = FutureProvider<int>(
  (ref) async {
    // TODO: Get current user ID from auth state
    final currentUserId = 'current_user_id'; // Replace with actual user ID
    final repository = ref.read(chatRepositoryProvider);
    return repository.getUnreadMessageCount(currentUserId);
  },
);
