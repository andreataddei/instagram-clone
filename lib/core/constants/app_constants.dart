class AppConstants {
  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // App
  static const String appName = 'Instagram Clone';
  static const String packageName = 'com.andreataddei.instagramclone';
  static const int appVersion = 1;
  static const String appVersionName = '1.0.0';

  // API
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);

  // Storage
  static const String storageBucket = 'instagram-clone';
  static const String postMediasFolder = 'post-medias';
  static const String storyMediasFolder = 'story-medias';
  static const String avatarFolder = 'avatars';
  static const String chatMediasFolder = 'chat-medias';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Validation
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 150;
  static const int maxCaptionLength = 2200;
  static const int maxCommentLength = 1000;

  // Media
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxMediaCountPerPost = 10;
  static const Duration storyDuration = Duration(hours: 24);

  // Deep Links
  static const String deepLinkScheme = 'io.github.andreataddei.instagramclone';
  static const String deepLinkHost = 'login-callback';
}
