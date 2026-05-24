import 'package:flutter/material.dart';
import 'package:instagram_clone/core/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final bool isFullScreen;
  final Color? color;
  final double? size;

  const LoadingWidget({
    super.key,
    this.isFullScreen = false,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Center(
      child: SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppTheme.primaryColor,
          ),
        ),
      ),
    );

    if (isFullScreen) {
      return Container(
        color: Colors.white.withOpacity(0.8),
        child: Center(child: widget),
      );
    }

    return widget;
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Stack(
      children: [
        child,
        const Positioned.fill(
          child: LoadingWidget(isFullScreen: true),
        ),
      ],
    );
  }
}
