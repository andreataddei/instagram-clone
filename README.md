# Instagram Clone - Flutter App

A complete Instagram clone application built with Flutter, Riverpod, and Supabase.

## Features

### Authentication
- Email/Password Sign Up & Login
- Google Sign In
- Forgot Password / Reset Password
- Email Verification

### Core Features
- **Feed**: View posts from followed users
- **Explore**: Discover new content and hashtags
- **Stories**: Create and view 24-hour stories
- **Chat**: Direct messaging with other users
- **Profile**: User profiles with posts grid
- **Notifications**: Real-time notifications

### Additional Features
- Post creation with multiple images
- Like, comment, and save posts
- Follow/unfollow users
- Search users and hashtags
- Settings and privacy controls

## Tech Stack

- **Flutter**: UI Framework
- **Riverpod**: State Management
- **Supabase**: Backend (Auth, Database, Storage)
- **GoRouter**: Navigation
- **Freezed**: Immutable Models
- **Image Picker**: Camera and Gallery access

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           ├── forgot_password_screen.dart
│   │           ├── login_screen.dart
│   │           └── signup_screen.dart
│   ├── chat/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── chat_model.dart
│   │   │   │   └── message_model.dart
│   │   │   └── repositories/
│   │   │       └── chat_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── chat_provider.dart
│   │       └── screens/
│   │           ├── chat_detail_screen.dart
│   │           ├── chat_list_screen.dart
│   │           └── notifications_screen.dart
│   ├── explore/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── explore_screen.dart
│   │           ├── hashtag_screen.dart
│   │           └── search_screen.dart
│   ├── feed/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── post_model.dart
│   │   │   └── repositories/
│   │   │       └── post_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── post_provider.dart
│   │       └── screens/
│   │           ├── create_post_screen.dart
│   │           └── feed_screen.dart
│   │       └── widgets/
│   │           └── post_card.dart
│   ├── profile/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── profile_model.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── profile_provider.dart
│   │       └── screens/
│   │           ├── edit_profile_screen.dart
│   │           └── profile_screen.dart
│   ├── settings/
│   │   └── presentation/
│   │       └── screens/
│   │           └── settings_screen.dart
│   ├── splash/
│   │   └── presentation/
│   │       └── screens/
│   │           └── splash_screen.dart
│   └── stories/
│       ├── data/
│       │   ├── models/
│       │   │   └── story_model.dart
│       │   └── repositories/
│       │       └── story_repository.dart
│       └── presentation/
│           ├── providers/
│           │   └── story_provider.dart
│           └── screens/
│               ├── create_story_screen.dart
│               └── stories_screen.dart
├── routes/
│   └── app_router.dart
├── shared/
│   └── widgets/
│       ├── bottom_nav_bar.dart
│       ├── error_widget.dart
│       └── loading_widget.dart
└── main.dart
└── pubspec.yaml
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Supabase account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/andreataddei/instagram-clone.git
cd instagram-clone
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code:
```bash
flutter pub run build_runner build
```

4. Set up Supabase:
   - Create a new project on [Supabase](https://supabase.com)
   - Create the following tables (SQL provided below)
   - Update `lib/core/constants/app_constants.dart` with your Supabase URL and anon key

5. Run the app:
```bash
flutter run
```

## Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Or update directly in `lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### Supabase Tables

Run the following SQL to create the required tables:

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT NOT NULL UNIQUE,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ,
  is_email_verified BOOLEAN DEFAULT FALSE,
  phone_number TEXT,
  provider TEXT DEFAULT 'email',
  metadata JSONB
);

-- Profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  bio TEXT,
  website TEXT,
  is_private BOOLEAN DEFAULT FALSE,
  post_count INTEGER DEFAULT 0,
  follower_count INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  gender TEXT
);

-- Posts table
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  user_avatar TEXT,
  caption TEXT,
  image_urls TEXT[] NOT NULL,
  likes UUID[] DEFAULT '{}',
  comments TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  location TEXT,
  hashtags TEXT[] DEFAULT '{}'
);

-- Stories table
CREATE TABLE stories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  user_avatar TEXT,
  image_url TEXT NOT NULL,
  video_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '24 hours',
  viewers UUID[] DEFAULT '{}',
  is_video BOOLEAN DEFAULT FALSE,
  caption TEXT,
  location TEXT,
  hashtags TEXT[] DEFAULT '{}',
  background_color TEXT,
  text_color TEXT,
  font_style TEXT
);

-- Chats table
CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  participant_ids UUID[] NOT NULL,
  last_message TEXT,
  last_message_time TIMESTAMPTZ,
  last_message_sender_id UUID,
  is_group BOOLEAN DEFAULT FALSE,
  group_name TEXT,
  group_avatar TEXT,
  group_admins UUID[],
  unread_count INTEGER DEFAULT 0,
  is_muted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_read BOOLEAN DEFAULT FALSE,
  type TEXT DEFAULT 'text',
  image_url TEXT,
  video_url TEXT,
  audio_url TEXT,
  metadata JSONB
);

-- Followers table
CREATE TABLE followers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

-- Notifications table
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
  sender_username TEXT,
  sender_avatar TEXT,
  post_id UUID REFERENCES posts(id) ON DELETE SET NULL,
  comment_id UUID,
  chat_id UUID REFERENCES chats(id) ON DELETE SET NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Comments table
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  user_avatar TEXT,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  likes UUID[] DEFAULT '{}'
);

-- Likes table
CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Saved Posts table
CREATE TABLE saved_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

-- Create indexes for better performance
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_stories_user_id ON stories(user_id);
CREATE INDEX idx_stories_expires_at ON stories(expires_at);
CREATE INDEX idx_chats_participant_ids ON chats USING GIN (participant_ids);
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sent_at ON messages(sent_at);
CREATE INDEX idx_followers_follower_id ON followers(follower_id);
CREATE INDEX idx_followers_following_id ON followers(following_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
```

## Running the App

### Development
```bash
flutter run
```

### Build for Production

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## Architecture

This app follows **Clean Architecture** principles with the following layers:

1. **Presentation Layer**: UI components, widgets, and state management (Riverpod)
2. **Domain Layer**: Business logic, models, and use cases
3. **Data Layer**: Data sources (Supabase), repositories, and data models

### State Management

The app uses **Riverpod** for state management with the following patterns:
- `Provider`: For simple dependencies
- `StateNotifierProvider`: For complex state that changes over time
- `FutureProvider`: For asynchronous operations
- `StreamProvider`: For real-time data

### Navigation

The app uses **GoRouter** for declarative navigation with:
- Named routes
- Path parameters
- Shell routes for bottom navigation
- Redirects based on authentication state

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
