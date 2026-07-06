import 'package:flutter/material.dart';
import 'package:event/notification_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider/provider.dart';

class NotificationButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double iconSize;
  final Color? iconColor;

  const NotificationButton({
    super.key,
    required this.onPressed,
    this.iconSize = 24.0,
    this.iconColor,
  });

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isInitialized = false;
  bool _isAnimating = false;
  @override
  void initState() {
    super.initState();

    // Use late final for better performance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener(_handleAnimationStatus);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_animationController);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _animationController.reverse();
    }
    _isAnimating =
        status == AnimationStatus.forward || status == AnimationStatus.reverse;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;
      // Use post-frame callback to avoid build phase issues
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadNotificationsIfNeeded();
      });
    }
  }

  Future<void> _loadNotificationsIfNeeded() async {
    if (!mounted) return;

    final notifier = context.read<NotificationNotifier>();
    final userNotifier = context.read<AppUserNotifier>();
    final userId = userNotifier.appUser?.idAppUser ?? 0;

    // More comprehensive checks
    final shouldLoad = userId > 0 &&
        notifier.notifications.notifications.isEmpty &&
        !notifier.isLoading;
    if (shouldLoad) {
      // Optional: Add a small delay to avoid blocking the initial build
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        notifier.loadInitialNotifications(userId);
      }
    }
  }

  @override
  void dispose() {
    _animationController
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!mounted || _isAnimating) return;

    try {
      _isAnimating = true;
      await _animationController.forward(from: 0.0);
    } finally {
      _isAnimating = false;
    }

    // Execute the callback after animation
    if (mounted) {
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = widget.iconColor ?? colorScheme.onSurface;

    return Consumer<NotificationNotifier>(
      builder: (context, notifier, child) {
        final unreadCount = notifier.unreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  size: widget.iconSize,
                  color: iconColor,
                ),
                onPressed: _handleTap,
                tooltip: 'Notifications',
              ),
            ),
            if (unreadCount > 0)
              _buildNotificationBadge(unreadCount, colorScheme),
          ],
        );
      },
    );
  }

  Widget _buildNotificationBadge(int count, ColorScheme colorScheme) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.surface,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.error.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: const BoxConstraints(
          minWidth: 16,
          minHeight: 16,
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
