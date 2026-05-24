import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/core/theme/app_theme.dart';
import 'package:instagram_clone/shared/widgets/error_widget.dart';
import 'package:instagram_clone/shared/widgets/loading_widget.dart';

// Notification Model
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? userId;
  final String? username;
  final String? avatarUrl;
  final DateTime timestamp;
  final bool isRead;
  final String? postId;
  final String? commentId;
  final String? chatId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.userId,
    this.username,
    this.avatarUrl,
    required this.timestamp,
    this.isRead = false,
    this.postId,
    this.commentId,
    this.chatId,
  });

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${difference.inDays ~/ 7}w';
    }
  }
}

// Notification Repository
class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(String userId) async {
    // TODO: Implement actual notification fetching from Supabase
    // For now, return mock data
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      NotificationModel(
        id: '1',
        type: 'like',
        title: 'Liked your post',
        message: 'user1 liked your post',
        userId: 'user1',
        username: 'user1',
        avatarUrl: null,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        postId: 'post1',
      ),
      NotificationModel(
        id: '2',
        type: 'comment',
        title: 'Commented on your post',
        message: 'user2 commented: "Nice photo!"',
        userId: 'user2',
        username: 'user2',
        avatarUrl: null,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        postId: 'post2',
        commentId: 'comment1',
      ),
      NotificationModel(
        id: '3',
        type: 'follow',
        title: 'Followed you',
        message: 'user3 started following you',
        userId: 'user3',
        username: 'user3',
        avatarUrl: null,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];
  }

  Future<void> markAsRead(String notificationId) async {
    // TODO: Implement mark as read
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> markAllAsRead(String userId) async {
    // TODO: Implement mark all as read
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

// Notification Provider
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(),
);

final notificationsProvider = FutureProvider<List<NotificationModel>>(
  (ref) async {
    // TODO: Get current user ID from auth state
    final currentUserId = 'current_user_id';
    return ref.read(notificationRepositoryProvider).getNotifications(currentUserId);
  },
);

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to notification settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(notificationsProvider);
        },
        child: notificationsAsync.when(
          loading: () => const LoadingWidget(isFullScreen: true),
          error: (error, stack) => ErrorWidget(
            message: error.toString(),
            onRetry: () => ref.refresh(notificationsProvider),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return const Center(
                child: Text('No new notifications'),
              );
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _NotificationItem(
                  notification: notifications[index],
                  onTap: () {
                    // Mark as read
                    ref.read(notificationRepositoryProvider).markAsRead(
                      notifications[index].id,
                    );
                    
                    // Navigate based on notification type
                    _handleNotificationTap(notifications[index]);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    switch (notification.type) {
      case 'like':
      case 'comment':
        if (notification.postId != null) {
          context.push('/post/${notification.postId}');
        }
        break;
      case 'follow':
        if (notification.userId != null) {
          context.push('/profile/${notification.userId}');
        }
        break;
      case 'message':
        if (notification.chatId != null) {
          context.push('/chat-detail/${notification.chatId}');
        }
        break;
    }
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        child: Text(
          notification.username?.substring(0, 1).toUpperCase() ?? '?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: notification.username ?? 'User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: ' ${notification.message}',
              style: TextStyle(
                color: notification.isRead ? Colors.grey[600] : Colors.black,
              ),
            ),
          ],
        ),
      ),
      subtitle: Text(
        notification.formattedTime,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
      onTap: onTap,
    );
  }
}
