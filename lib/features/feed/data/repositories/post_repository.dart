import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:instagram_clone/core/constants/app_constants.dart';
import 'package:instagram_clone/features/feed/data/models/post_model.dart';

class PostRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Table name
  static const String _tableName = AppConstants.postsTable;

  // Create a new post
  Future<PostModel> createPost(PostModel post) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(post.toJson())
          .select()
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to create post: ${response.error!.message}');
      }

      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Get all posts (feed)
  Future<List<PostModel>> getFeedPosts({int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get posts: ${response.error!.message}');
      }

      final posts = (response.data as List<dynamic>?)
          ?.map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return posts;
    } catch (e) {
      throw Exception('Failed to get posts: $e');
    }
  }

  // Get posts by user
  Future<List<PostModel>> getPostsByUser(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get user posts: ${response.error!.message}');
      }

      final posts = (response.data as List<dynamic>?)
          ?.map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return posts;
    } catch (e) {
      throw Exception('Failed to get user posts: $e');
    }
  }

  // Get single post by ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', postId)
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get post: ${response.error!.message}');
      }

      if (response.data == null) return null;

      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  // Like/Unlike a post
  Future<PostModel> toggleLike(String postId, String userId) async {
    try {
      // First get the current post
      final currentPost = await getPostById(postId);
      if (currentPost == null) {
        throw Exception('Post not found');
      }

      final newLikes = currentPost.likes.contains(userId)
          ? currentPost.likes.where((id) => id != userId).toList()
          : [...currentPost.likes, userId];

      final response = await _supabase
          .from(_tableName)
          .update({'likes': newLikes})
          .eq('id', postId)
          .select()
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to update like: ${response.error!.message}');
      }

      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .delete()
          .eq('id', postId)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to delete post: ${response.error!.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Get posts by hashtag
  Future<List<PostModel>> getPostsByHashtag(String hashtag) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .contains('hashtags', [hashtag])
          .order('created_at', ascending: false)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get posts by hashtag: ${response.error!.message}');
      }

      final posts = (response.data as List<dynamic>?)
          ?.map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return posts;
    } catch (e) {
      throw Exception('Failed to get posts by hashtag: $e');
    }
  }
}
