import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/core/theme/app_theme.dart';
import 'package:instagram_clone/features/feed/presentation/providers/post_provider.dart';
import 'package:instagram_clone/features/profile/presentation/providers/profile_provider.dart';
import 'package:instagram_clone/shared/widgets/error_widget.dart';
import 'package:instagram_clone/shared/widgets/loading_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile and posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider(widget.userId).notifier).loadProfile(widget.userId);
      ref.read(userPostsProvider(widget.userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider(widget.userId));
    final postsAsync = ref.watch(userPostsProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          profileState.profile?.username ?? 'Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.userId == 'current_user_id') // TODO: Replace with actual current user ID
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show profile options menu
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(profileProvider(widget.userId).notifier).loadProfile(widget.userId);
          ref.refresh(userPostsProvider(widget.userId));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                profileState: profileState,
                userId: widget.userId,
              ),
            ),
            SliverToBoxAdapter(
              child: _ProfileStats(
                profile: profileState.profile,
                isOwnProfile: widget.userId == 'current_user_id', // TODO: Replace with actual current user ID
              ),
            ),
            SliverToBoxAdapter(
              child: _ProfileBio(profile: profileState.profile),
            ),
            SliverToBoxAdapter(
              child: _ProfileTabs(profile: profileState.profile),
            ),
            _ProfilePostsGrid(postsAsync: postsAsync),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final ProfileState profileState;
  final String userId;

  const _ProfileHeader({
    required this.profileState,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profileState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: LoadingWidget(),
      );
    }

    if (profileState.error != null) {
      return ErrorWidget(
        message: profileState.error!,
        onRetry: () => ref.read(profileProvider(userId).notifier).loadProfile(userId),
      );
    }

    final profile = profileState.profile;
    if (profile == null) {
      return const Center(
        child: Text('Profile not found'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              // TODO: Show avatar full screen
            },
            child: CircleAvatar(
              radius: 40,
              backgroundImage: profile.hasAvatar
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: !profile.hasAvatar
                  ? Text(
                      profile.initials,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          
          // Follow/Edit Profile Button
          Expanded(
            child: _buildActionButton(profileState, profile, context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    ProfileState profileState,
    ProfileModel profile,
    BuildContext context,
    WidgetRef ref,
  ) {
    final isOwnProfile = userId == 'current_user_id'; // TODO: Replace with actual current user ID

    if (isOwnProfile) {
      return OutlinedButton(
        onPressed: () => context.push('/edit-profile'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: const Text('Edit Profile'),
      );
    }

    if (profileState.isLoadingFollow) {
      return const LoadingWidget();
    }

    return ElevatedButton(
      onPressed: () => ref.read(profileProvider(userId).notifier).toggleFollow(userId),
      style: ElevatedButton.styleFrom(
        backgroundColor: profileState.isFollowing ? Colors.grey[200] : AppTheme.primaryColor,
        foregroundColor: profileState.isFollowing ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(
        profileState.isFollowing ? 'Following' : 'Follow',
        style: TextStyle(
          color: profileState.isFollowing ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final ProfileModel? profile;
  final bool isOwnProfile;

  const _ProfileStats({
    required this.profile,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (profile == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            count: profile!.postCount ?? 0,
            label: 'Posts',
          ),
          _StatItem(
            count: profile!.followerCount ?? 0,
            label: 'Followers',
            onTap: () {
              // TODO: Navigate to followers list
            },
          ),
          _StatItem(
            count: profile!.followingCount ?? 0,
            label: 'Following',
            onTap: () {
              // TODO: Navigate to following list
            },
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback? onTap;

  const _StatItem({
    required this.count,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            _formatCount(count),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _ProfileBio extends StatelessWidget {
  final ProfileModel? profile;

  const _ProfileBio({required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile!.fullName?.isNotEmpty == true)
            Text(
              profile!.fullName!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (profile!.fullName?.isNotEmpty == true) const SizedBox(height: 4),
          if (profile!.bio?.isNotEmpty == true)
            Text(
              profile!.bio!,
              style: const TextStyle(fontSize: 14),
            ),
          if (profile!.bio?.isNotEmpty == true) const SizedBox(height: 4),
          if (profile!.website?.isNotEmpty == true)
            GestureDetector(
              onTap: () {
                // TODO: Open website URL
              },
              child: Text(
                profile!.website!,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  final ProfileModel? profile;

  const _ProfileTabs({required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile == null) return const SizedBox.shrink();

    return DefaultTabController(
      length: 2,
      child: TabBar(
        indicatorColor: Colors.black,
        tabs: const [
          Tab(
            icon: Icon(Icons.grid_on_outlined),
          ),
          Tab(
            icon: Icon(Icons.person_pin_outlined),
          ),
        ],
      ),
    );
  }
}

class _ProfilePostsGrid extends StatelessWidget {
  final AsyncValue<List<dynamic>> postsAsync;

  const _ProfilePostsGrid({required this.postsAsync});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(1),
      sliver: postsAsync.when(
        loading: () => const SliverToBoxAdapter(child: LoadingWidget()),
        error: (error, stack) => SliverToBoxAdapter(
          child: ErrorWidget(
            message: error.toString(),
            onRetry: () => context.refresh(),
          ),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No posts yet'),
                ),
              ),
            );
          }

          return SliverGrid(
            delegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return GestureDetector(
                  onTap: () {
                    // TODO: Navigate to post detail
                  },
                  child: Image.network(
                    posts[index].firstImageUrl,
                    fit: BoxFit.cover,
                  ),
                );
              },
              childCount: posts.length,
            ),
          );
        },
      ),
    );
  }
}
