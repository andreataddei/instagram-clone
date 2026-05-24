import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/features/feed/data/models/post_model.dart';
import 'package:instagram_clone/features/feed/data/repositories/post_repository.dart';

// Post Repository Provider
final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(),
);

// Post State
class PostState {
  final bool isLoading;
  final List<PostModel> posts;
  final String? error;
  final bool hasReachedMax;

  const PostState({
    this.isLoading = false,
    this.posts = const [],
    this.error,
    this.hasReachedMax = false,
  });

  PostState copyWith({
    bool? isLoading,
    List<PostModel>? posts,
    String? error,
    bool? hasReachedMax,
  }) {
    return PostState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

// Feed Posts Notifier
class FeedPostsNotifier extends StateNotifier<PostState> {
  final PostRepository _postRepository;
  int _page = 0;
  static const int _pageSize = 20;

  FeedPostsNotifier(this._postRepository) : super(const PostState());

  Future<void> loadFeedPosts({bool refresh = false}) async {
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
      final posts = await _postRepository.getFeedPosts(
        limit: _pageSize,
        offset: _page * _pageSize,
      );

      if (refresh) {
        state = state.copyWith(
          posts: posts,
          isLoading: false,
          hasReachedMax: posts.length < _pageSize,
        );
      } else {
        state = state.copyWith(
          posts: [...state.posts, ...posts],
          isLoading: false,
          hasReachedMax: posts.length < _pageSize,
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

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final updatedPost = await _postRepository.toggleLike(postId, userId);
      state = state.copyWith(
        posts: state.posts.map((post) {
          if (post.id == postId) {
            return updatedPost;
          }
          return post;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Feed Posts Provider
final feedPostsProvider = StateNotifierProvider<FeedPostsNotifier, PostState>(
  (ref) {
    return FeedPostsNotifier(ref.read(postRepositoryProvider));
  },
);

// Single Post Provider
final postProvider = FutureProvider.family<PostModel?, String>(
  (ref, postId) async {
    final repository = ref.read(postRepositoryProvider);
    return repository.getPostById(postId);
  },
);

// User Posts Provider
final userPostsProvider = FutureProvider.family<List<PostModel>, String>(
  (ref, userId) async {
    final repository = ref.read(postRepositoryProvider);
    return repository.getPostsByUser(userId);
  },
);
