import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_clone/core/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            isActive: currentIndex == 0,
            onTap: () => context.go('/feed'),
            label: 'Home',
          ),
          _NavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            isActive: currentIndex == 1,
            onTap: () => context.go('/explore'),
            label: 'Explore',
          ),
          _NavItem(
            icon: Icons.add_box_outlined,
            activeIcon: Icons.add_box,
            isActive: currentIndex == 2,
            onTap: () => context.go('/create-post'),
            label: 'Create',
          ),
          _NavItem(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            isActive: currentIndex == 3,
            onTap: () => context.go('/notifications'),
            label: 'Notifications',
          ),
          _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            isActive: currentIndex == 4,
            onTap: () => context.go('/profile'),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppTheme.primaryColor : Colors.black,
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryColor : Colors.black,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
