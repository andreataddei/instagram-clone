import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/features/profile/data/models/profile_model.dart';
import 'package:instagram_clone/features/profile/data/repositories/profile_repository.dart';

// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

// Profile State
class ProfileState {
  final bool isLoading;
  final ProfileModel? profile;
  final String? error;
  final bool isFollowing;
  final bool isLoadingFollow;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
    this.isFollowing = false,
    this.isLoadingFollow = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    ProfileModel? profile,
    String? error,
    bool? isFollowing,
    bool? isLoadingFollow,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
      isFollowing: isFollowing ?? this.isFollowing,
      isLoadingFollow: isLoadingFollow ?? this.isLoadingFollow,
    );
  }
}

// Profile Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _profileRepository;
  final String _currentUserId; // TODO: Get from auth state

  ProfileNotifier(this._profileRepository, this._currentUserId) 
      : super(const ProfileState());

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _profileRepository.getProfileById(userId);
      if (profile == null) {
        throw Exception('Profile not found');
      }

      final isFollowing = _currentUserId != userId &&
          await _profileRepository.isFollowing(_currentUserId, userId);

      state = state.copyWith(
        profile: profile,
        isFollowing: isFollowing,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> toggleFollow(String userId) async {
    if (state.isLoadingFollow) return;

    state = state.copyWith(isLoadingFollow: true);

    try {
      if (state.isFollowing) {
        await _profileRepository.unfollowUser(_currentUserId, userId);
        state = state.copyWith(
          isFollowing: false,
          profile: state.profile?.copyWith(
            followerCount: (state.profile?.followerCount ?? 0) - 1,
          ),
          isLoadingFollow: false,
        );
      } else {
        await _profileRepository.followUser(_currentUserId, userId);
        state = state.copyWith(
          isFollowing: true,
          profile: state.profile?.copyWith(
            followerCount: (state.profile?.followerCount ?? 0) + 1,
          ),
          isLoadingFollow: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingFollow: false,
      );
    }
  }

  Future<void> updateProfile(ProfileModel profile) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedProfile = await _profileRepository.updateProfile(profile);
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

// Profile Provider
final profileProvider = StateNotifierProvider.family<
    ProfileNotifier, ProfileState, String>(
  (ref, userId) {
    // TODO: Get current user ID from auth state
    final currentUserId = 'current_user_id'; // Replace with actual user ID
    return ProfileNotifier(
      ref.read(profileRepositoryProvider),
      currentUserId,
    );
  },
);

// Current User Profile Provider
final currentUserProfileProvider = FutureProvider<ProfileModel?>(
  (ref) async {
    // TODO: Get current user ID from auth state
    final currentUserId = 'current_user_id'; // Replace with actual user ID
    final repository = ref.read(profileRepositoryProvider);
    return repository.getProfileById(currentUserId);
  },
);

// Search Profiles Provider
final searchProfilesProvider = FutureProvider.family<
    List<ProfileModel>, String>(
  (ref, query) async {
    final repository = ref.read(profileRepositoryProvider);
    return repository.searchProfiles(query);
  },
);
