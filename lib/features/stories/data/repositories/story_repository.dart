import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:instagram_clone/core/constants/app_constants.dart';
import 'package:instagram_clone/features/stories/data/models/story_model.dart';

class StoryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Table name
  static const String _tableName = AppConstants.storiesTable;

  // Create a new story
  Future<StoryModel> createStory(StoryModel story) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(story.toJson())
          .select()
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to create story: ${response.error!.message}');
      }

      return StoryModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create story: $e');
    }
  }

  // Get stories for followed users
  Future<List<StoryModel>> getStoriesForFeed(String userId) async {
    try {
      // First, get followed users
      final followersResponse = await _supabase
          .from(AppConstants.followersTable)
          .select('following_id')
          .eq('follower_id', userId)
          .execute();

      if (followersResponse.error != null) {
        throw Exception('Failed to get followed users: ${followersResponse.error!.message}');
      }

      final followedUserIds = (followersResponse.data as List<dynamic>?)
          ?.map((e) => (e as Map<String, dynamic>)['following_id'] as String)
          .toList() ?? [];

      // Add current user's stories
      followedUserIds.add(userId);

      // Get stories from followed users
      final response = await _supabase
          .from(_tableName)
          .select()
          .in_('user_id', followedUserIds)
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get stories: ${response.error!.message}');
      }

      final stories = (response.data as List<dynamic>?)
          ?.map((e) => StoryModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return stories;
    } catch (e) {
      throw Exception('Failed to get stories: $e');
    }
  }

  // Get stories by user
  Future<List<StoryModel>> getStoriesByUser(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get user stories: ${response.error!.message}');
      }

      final stories = (response.data as List<dynamic>?)
          ?.map((e) => StoryModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return stories;
    } catch (e) {
      throw Exception('Failed to get user stories: $e');
    }
  }

  // Get single story by ID
  Future<StoryModel?> getStoryById(String storyId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', storyId)
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get story: ${response.error!.message}');
      }

      if (response.data == null) return null;

      return StoryModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get story: $e');
    }
  }

  // Mark story as viewed
  Future<StoryModel> markStoryAsViewed(String storyId, String viewerId) async {
    try {
      // First get the current story
      final currentStory = await getStoryById(storyId);
      if (currentStory == null) {
        throw Exception('Story not found');
      }

      // Add viewer if not already in the list
      final newViewers = currentStory.viewers.contains(viewerId)
          ? currentStory.viewers
          : [...currentStory.viewers, viewerId];

      final response = await _supabase
          .from(_tableName)
          .update({'viewers': newViewers})
          .eq('id', storyId)
          .select()
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to mark story as viewed: ${response.error!.message}');
      }

      return StoryModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to mark story as viewed: $e');
    }
  }

  // Delete a story
  Future<void> deleteStory(String storyId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .delete()
          .eq('id', storyId)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to delete story: ${response.error!.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  // Check if user has active stories
  Future<bool> hasActiveStories(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', userId)
          .gte('expires_at', DateTime.now().toIso8601String())
          .execute();

      if (response.error != null) {
        throw Exception('Failed to check active stories: ${response.error!.message}');
      }

      return (response.count ?? 0) > 0;
    } catch (e) {
      throw Exception('Failed to check active stories: $e');
    }
  }
}

// Helper class for Supabase count option
class CountOption {
  static const exact = 'exact';
}

// Helper class for Supabase fetch options
class FetchOptions {
  final dynamic count;
  const FetchOptions({this.count});
}
