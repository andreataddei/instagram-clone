import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/features/feed/presentation/providers/post_provider.dart';
import 'package:instagram_clone/features/feed/presentation/widgets/post_card.dart';
import 'package:instagram_clone/shared/widgets/error_widget.dart';
import 'package:instagram_clone/shared/widgets/loading_widget.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedPostsProvider.notifier).loadFeedPosts(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(feedPostsProvider.notifier).loadFeedPosts();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(feedPostsProvider.notifier).loadFeedPosts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(feedPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontFamily: 'Billabong',
            fontSize: 32,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: () => Navigator.pushNamed(context, '/chat-list'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Builder(
          builder: (context) {
            if (postState.isLoading && postState.posts.isEmpty) {
              return const LoadingWidget(isFullScreen: true);
            }

            if (postState.error != null) {
              return ErrorWidget(
                message: postState.error!,
                onRetry: () => ref.read(feedPostsProvider.notifier).loadFeedPosts(refresh: true),
              );
            }

            if (postState.posts.isEmpty) {
              return const Center(
                child: Text('No posts yet. Follow users to see their posts!'),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: postState.posts.length + (postState.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == postState.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LoadingWidget(),
                  );
                }
                return PostCard(
                  post: postState.posts[index],
                  onLikeToggle: () => ref.read(feedPostsProvider.notifier).toggleLike(
                    postState.posts[index].id,
                    'current_user_id', // TODO: Replace with actual user ID
                  ),
                  onComment: () {
                    // TODO: Navigate to comments
                  },
                  onShare: () {
                    // TODO: Implement share
                  },
                  onSave: () {
                    // TODO: Implement save
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
