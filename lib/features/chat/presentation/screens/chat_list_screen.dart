import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/core/theme/app_theme.dart';
import 'package:instagram_clone/features/chat/presentation/providers/chat_provider.dart';
import 'package:instagram_clone/shared/widgets/error_widget.dart';
import 'package:instagram_clone/shared/widgets/loading_widget.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Load chats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatsProvider.notifier).loadChats(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatsState = ref.watch(chatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show chat options menu
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(chatsProvider.notifier).loadChats(refresh: true);
        },
        child: Builder(
          builder: (context) {
            if (chatsState.isLoading && chatsState.chats.isEmpty) {
              return const LoadingWidget(isFullScreen: true);
            }

            if (chatsState.error != null) {
              return ErrorWidget(
                message: chatsState.error!,
                onRetry: () => ref.read(chatsProvider.notifier).loadChats(refresh: true),
              );
            }

            if (chatsState.chats.isEmpty) {
              return const Center(
                child: Text('No messages yet. Start a conversation!'),
              );
            }

            return ListView.builder(
              itemCount: chatsState.chats.length,
              itemBuilder: (context, index) {
                final chat = chatsState.chats[index];
                return _ChatItem(
                  chat: chat,
                  onTap: () {
                    // Mark as read when opening
                    ref.read(chatsProvider.notifier).markChatAsRead(chat.id);
                    context.push('/chat-detail/${chat.id}');
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          // TODO: Navigate to new chat
          context.push('/new-chat');
        },
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const _ChatItem({
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        child: Text(
          chat.chatName.substring(0, 1).toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Row(
        children: [
          Text(
            chat.chatName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (chat.isGroup) ...[
            const SizedBox(width: 4),
            const Icon(Icons.group_outlined, size: 14, color: Colors.grey),
          ],
        ],
      ),
      subtitle: Row(
        children: [
          if (chat.lastMessageSenderId == 'current_user_id') // TODO: Replace with actual user ID
            const Icon(Icons.done_all, size: 14, color: Colors.blue),
          if (chat.lastMessageSenderId == 'current_user_id') // TODO: Replace with actual user ID
            const SizedBox(width: 4),
          Expanded(
            child: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: chat.hasUnreadMessages ? Colors.black : Colors.grey,
                fontWeight: chat.hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.formattedLastMessageTime,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          if (chat.hasUnreadMessages)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
