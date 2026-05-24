import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/core/theme/app_theme.dart';
import 'package:instagram_clone/features/stories/presentation/providers/story_provider.dart';
import 'package:instagram_clone/shared/widgets/error_widget.dart';
import 'package:instagram_clone/shared/widgets/loading_widget.dart';

class StoriesScreen extends ConsumerStatefulWidget {
  const StoriesScreen({super.key});

  @override
  ConsumerState<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends ConsumerState<StoriesScreen> {
  @override
  void initState() {
    super.initState();
    // Load stories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storiesProvider.notifier).loadStories(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final storiesState = ref.watch(storiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Show story settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(storiesProvider.notifier).loadStories(refresh: true);
        },
        child: Builder(
          builder: (context) {
            if (storiesState.isLoading && storiesState.stories.isEmpty) {
              return const LoadingWidget(isFullScreen: true);
            }

            if (storiesState.error != null) {
              return ErrorWidget(
                message: storiesState.error!,
                onRetry: () => ref.read(storiesProvider.notifier).loadStories(refresh: true),
              );
            }

            if (storiesState.stories.isEmpty) {
              return const Center(
                child: Text('No stories to show. Follow users to see their stories!'),
              );
            }

            return ListView.builder(
              itemCount: storiesState.stories.length + 1, // +1 for "Your Story"
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _YourStoryCard(
                    onTap: () => context.push('/create-story'),
                  );
                }
                return _StoryCard(
                  story: storiesState.stories[index - 1],
                  onTap: () {
                    // TODO: Navigate to story viewer
                    context.push('/story-viewer/${storiesState.stories[index - 1].id}');
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

class _YourStoryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _YourStoryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF833AB4),
                    Color(0xFFFD1D1D),
                    Color(0xFFFFDC80),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Story',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends ConsumerWidget {
  final StoryModel story;
  final VoidCallback onTap;

  const _StoryCard({
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveStories = ref.watch(hasActiveStoriesProvider(story.userId));

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: story.isViewed
                    ? null
                    : const LinearGradient(
                        colors: [
                          Color(0xFF833AB4),
                          Color(0xFFFD1D1D),
                          Color(0xFFFFDC80),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundImage: story.userAvatar != null
                    ? NetworkImage(story.userAvatar!)
                    : null,
                child: story.userAvatar == null
                    ? Text(
                        story.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            story.username,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
