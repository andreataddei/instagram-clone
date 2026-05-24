import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/core/theme/app_theme.dart';
import 'package:instagram_clone/features/profile/data/models/profile_model.dart';
import 'package:instagram_clone/features/profile/presentation/providers/profile_provider.dart';
import 'package:instagram_clone/shared/widgets/loading_widget.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  XFile? _selectedAvatar;
  bool _isLoading = false;
  ProfileModel? _currentProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile != null) {
      setState(() {
        _currentProfile = profile;
        _usernameController.text = profile.username;
        _fullNameController.text = profile.fullName ?? '';
        _bioController.text = profile.bio ?? '';
        _websiteController.text = profile.website ?? '';
        _emailController.text = profile.email;
        _phoneController.text = profile.phoneNumber ?? '';
      });
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedAvatar = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _removeAvatar() async {
    setState(() {
      _selectedAvatar = null;
    });
  }

  Future<void> _saveProfile() async {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Upload avatar to Supabase Storage if changed
      String? avatarUrl = _currentProfile?.avatarUrl;

      final profile = ProfileModel(
        id: _currentProfile?.id ?? 'current_user_id', // TODO: Replace with actual user ID
        username: _usernameController.text,
        email: _emailController.text,
        fullName: _fullNameController.text.isEmpty ? null : _fullNameController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        website: _websiteController.text.isEmpty ? null : _websiteController.text,
        avatarUrl: avatarUrl,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        postCount: _currentProfile?.postCount,
        followerCount: _currentProfile?.followerCount,
        followingCount: _currentProfile?.followingCount,
        isPrivate: _currentProfile?.isPrivate,
        createdAt: _currentProfile?.createdAt,
        gender: _currentProfile?.gender,
      );

      await ref.read(profileRepositoryProvider).updateProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const LoadingWidget(size: 20)
                : const Text(
                    'Done',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: _currentProfile == null
          ? const LoadingWidget(isFullScreen: true)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    _buildAvatarSection(),
                    const SizedBox(height: 24),

                    // Username
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Enter username',
                    ),
                    const SizedBox(height: 16),

                    // Full Name
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Tell something about yourself',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Website
                    _buildTextField(
                      controller: _websiteController,
                      label: 'Website',
                      hint: 'Enter your website URL',
                      prefixIcon: Icons.language_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      hint: 'Enter your phone number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),

                    // Private Account Toggle
                    _buildPrivateAccountToggle(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Photo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _selectedAvatar != null
                    ? FileImage(File(_selectedAvatar!.path))
                    : _currentProfile?.hasAvatar == true
                        ? NetworkImage(_currentProfile!.avatarUrl!)
                        : null,
                child: !_currentProfile!.hasAvatar && _selectedAvatar == null
                    ? Text(
                        _currentProfile!.initials,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: maxLines,
          readOnly: readOnly,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildPrivateAccountToggle() {
    return Row(
      children: [
        const Text(
          'Private Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Switch(
          value: _currentProfile?.isPrivate ?? false,
          onChanged: (value) {
            setState(() {
              _currentProfile = _currentProfile!.copyWith(isPrivate: value);
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }
}
