import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/features/stories/data/models/story_model.dart';
import 'package:instagram_clone/features/stories/data/repositories/story_repository.dart';

// Story Repository Provider
final storyRepositoryProvider = Provider<StoryRepository>(
  (ref) => StoryRepository(),
);

// Story State
class StoryState {
  final bool isLoading;
  final List<StoryModel> stories;
  final String? error;
  final bool hasReachedMax;

  const StoryState({
    this.isLoading = false,
    this.stories = const [],
    this.error,
    this.hasReachedMax = false,
  });

  StoryState copyWith({
    bool? isLoading,
    List<StoryModel>? stories,
    String? error,
    bool? hasReachedMax,
  }) {
    return StoryState(
      isLoading: isLoading ?? this.isLoading,
      stories: stories ?? this.stories,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

// Stories Notifier
class StoriesNotifier extends StateNotifier<StoryState> {
  final StoryRepository _storyRepository;
  final String _currentUserId; // TODO: Get from auth state

  StoriesNotifier(this._storyRepository, this._currentUserId) 
      : super(const StoryState());

  Future<void> loadStories({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        hasReachedMax: false,
      );
    } else if (state.hasReachedMax || state.isLoading) {
      return;
    }

    try {
      final stories = await _storyRepository.getStoriesForFeed(_currentUserId);

      // Group stories by user and get the most recent one for each
      final storyMap = <String, StoryModel>{};
      for (final story in stories) {
        if (!storyMap.containsKey(story.userId) ||
            story.createdAt.isAfter(storyMap[story.userId]!.createdAt)) {
          storyMap[story.userId] = story;
        }
      }

      final uniqueStories = storyMap.values.toList();
      uniqueStories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (refresh) {
        state = state.copyWith(
          stories: uniqueStories,
          isLoading: false,
          hasReachedMax: uniqueStories.length < 20,
        );
      } else {
        state = state.copyWith(
          stories: [...state.stories, ...uniqueStories],
          isLoading: false,
          hasReachedMax: uniqueStories.length < 20,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> markStoryAsViewed(String storyId) async {
    try {
      await _storyRepository.markStoryAsViewed(storyId, _currentUserId);
      
      // Update the story in the state
      state = state.copyWith(
        stories: state.stories.map((story) {
          if (story.id == storyId) {
            return story.copyWith(
              viewers: [...story.viewers, _currentUserId],
            );
          }
          return story;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createStory(StoryModel story) async {
    try {
      final createdStory = await _storyRepository.createStory(story);
      // Refresh the stories
      await loadStories(refresh: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await _storyRepository.deleteStory(storyId);
      state = state.copyWith(
        stories: state.stories.where((story) => story.id != storyId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Stories Provider
final storiesProvider = StateNotifierProvider<StoriesNotifier, StoryState>(
  (ref) {
    // TODO: Get current user ID from auth state
    final currentUserId = 'current_user_id'; // Replace with actual user ID
    return StoriesNotifier(
      ref.read(storyRepositoryProvider),
      currentUserId,
    );
  },
);

// User Stories Provider
final userStoriesProvider = FutureProvider.family<List<StoryModel>, String>(
  (ref, userId) async {
    final repository = ref.read(storyRepositoryProvider);
    return repository.getStoriesByUser(userId);
  },
);

// Has Active Stories Provider
final hasActiveStoriesProvider = FutureProvider.family<bool, String>(
  (ref, userId) async {
    final repository = ref.read(storyRepositoryProvider);
    return repository.hasActiveStories(userId);
  },
);
