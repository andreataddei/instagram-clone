import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/features/auth/presentation/providers/auth_provider.dart';
import 'package:instagram_clone/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:instagram_clone/features/auth/presentation/screens/login_screen.dart';
import 'package:instagram_clone/features/auth/presentation/screens/signup_screen.dart';
import 'package:instagram_clone/features/chat/presentation/screens/chat_detail_screen.dart';
import 'package:instagram_clone/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:instagram_clone/features/chat/presentation/screens/notifications_screen.dart';
import 'package:instagram_clone/features/explore/presentation/screens/explore_screen.dart';
import 'package:instagram_clone/features/explore/presentation/screens/hashtag_screen.dart';
import 'package:instagram_clone/features/feed/presentation/screens/create_post_screen.dart';
import 'package:instagram_clone/features/feed/presentation/screens/feed_screen.dart';
import 'package:instagram_clone/features/feed/presentation/screens/post_detail_screen.dart';
import 'package:instagram_clone/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:instagram_clone/features/profile/presentation/screens/followers_screen.dart';
import 'package:instagram_clone/features/profile/presentation/screens/profile_screen.dart';
import 'package:instagram_clone/features/settings/presentation/screens/settings_screen.dart';
import 'package:instagram_clone/features/splash/presentation/screens/splash_screen.dart';
import 'package:instagram_clone/features/stories/presentation/screens/create_story_screen.dart';
import 'package:instagram_clone/features/stories/presentation/screens/stories_screen.dart';
import 'package:instagram_clone/features/shared/presentation/widgets/bottom_nav_bar.dart';

final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainAppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/create',
            builder: (context, state) => const CreatePostScreen(),
          ),
          GoRoute(
            path: '/activity',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/post/:postId',
        builder: (context, state) {
          final postId = state.pathParams['postId']!;
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/stories/:userId',
        builder: (context, state) {
          final userId = state.pathParams['userId']!;
          return StoriesScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/create-story',
        builder: (context, state) => const CreateStoryScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParams['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/followers/:userId',
        builder: (context, state) {
          final userId = state.pathParams['userId']!;
          return FollowersScreen(
            profileId: userId,
            showFollowers: true,
          );
        },
      ),
      GoRoute(
        path: '/following/:userId',
        builder: (context, state) {
          final userId = state.pathParams['userId']!;
          return FollowersScreen(
            profileId: userId,
            showFollowers: false,
          );
        },
      ),
      GoRoute(
        path: '/hashtag/:hashtag',
        builder: (context, state) {
          final hashtag = state.pathParams['hashtag']!;
          return HashtagScreen(hashtag: hashtag);
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParams['chatId']!;
          return ChatDetailScreen(chatId: chatId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = context.read(authNotifierProvider) is AuthStateAuthenticated;
      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.startsWith('/forgot-password');
      if (!isLoggedIn && !isSplash && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && (isAuthRoute || isSplash)) {
        return '/';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pagina non trovata',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Errore: ${state.error?.message ?? "Pagina non trovata"}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Torna alla home'),
            ),
          ],
        ),
      ),
    ),
  );
}

class MainAppShell extends ConsumerWidget {
  final Widget child;
  const MainAppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}