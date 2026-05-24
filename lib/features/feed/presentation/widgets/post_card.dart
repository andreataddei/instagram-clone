import 'package:flutter/material.dart';
import 'package:instagram_clone/core/theme/app_theme.dart';
import 'package:instagram_clone/features/feed/data/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLikeToggle;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const PostCard({
    super.key,
    required this.post,
    required this.onLikeToggle,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: post.userAvatar != null
                    ? NetworkImage(post.userAvatar!)
                    : null,
                child: post.userAvatar == null
                    ? Text(
                        post.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                post.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (post.location.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  post.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Show post options menu
                },
              ),
            ],
          ),
        ),
        
        // Post Image(s)
        Image.network(
          post.firstImageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
        ),
        
        // Post Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.favorite_outline,
                  color: Colors.black,
                  size: 26,
                ),
                onPressed: onLikeToggle,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.comment_outlined, size: 26),
                onPressed: onComment,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.send_outlined, size: 26),
                onPressed: onShare,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_outline, size: 26),
                onPressed: onSave,
              ),
            ],
          ),
        ),
        
        // Post Caption and Comments
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Like count
              Text(
                '${post.likeCount} likes',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              
              // Caption with username
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${post.username} ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: post.caption,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              
              // Time ago
              Text(
                _formatTimeAgo(post.createdAt),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }
}
