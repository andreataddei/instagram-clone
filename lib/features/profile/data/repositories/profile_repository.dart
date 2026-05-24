import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:instagram_clone/core/constants/app_constants.dart';
import 'package:instagram_clone/features/profile/data/models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Table name
  static const String _tableName = AppConstants.profilesTable;

  // Get profile by user ID
  Future<ProfileModel?> getProfileById(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', userId)
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get profile: ${response.error!.message}');
      }

      if (response.data == null) return null;

      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Get profile by username
  Future<ProfileModel?> getProfileByUsername(String username) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to get profile: ${response.error!.message}');
      }

      if (response.data == null) return null;

      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Create or update profile
  Future<ProfileModel> upsertProfile(ProfileModel profile) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .upsert(profile.toJson())
          .select()
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to upsert profile: ${response.error!.message}');
      }

      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to upsert profile: $e');
    }
  }

  // Update profile
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to update profile: ${response.error!.message}');
      }

      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Follow a user
  Future<void> followUser(String followerId, String followingId) async {
    try {
      // Add to followers table
      await _supabase
          .from(AppConstants.followersTable)
          .insert({
            'follower_id': followerId,
            'following_id': followingId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .execute();

      // Update follower count
      await _supabase
          .from(_tableName)
          .increment('follower_count', by: 1)
          .eq('id', followingId)
          .execute();

      // Update following count
      await _supabase
          .from(_tableName)
          .increment('following_count', by: 1)
          .eq('id', followerId)
          .execute();
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  // Unfollow a user
  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      // Remove from followers table
      await _supabase
          .from(AppConstants.followersTable)
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .execute();

      // Update follower count
      await _supabase
          .from(_tableName)
          .decrement('follower_count', by: 1)
          .eq('id', followingId)
          .execute();

      // Update following count
      await _supabase
          .from(_tableName)
          .decrement('following_count', by: 1)
          .eq('id', followerId)
          .execute();
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  // Check if user is following another user
  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final response = await _supabase
          .from(AppConstants.followersTable)
          .select()
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .single()
          .execute();

      if (response.error != null) {
        throw Exception('Failed to check follow: ${response.error!.message}');
      }

      return response.data != null;
    } catch (e) {
      throw Exception('Failed to check follow: $e');
    }
  }

  // Search profiles by username
  Future<List<ProfileModel>> searchProfiles(String query) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .ilike('username', '%$query%')
          .limit(10)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to search profiles: ${response.error!.message}');
      }

      final profiles = (response.data as List<dynamic>?)
          ?.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return profiles;
    } catch (e) {
      throw Exception('Failed to search profiles: $e');
    }
  }
}
