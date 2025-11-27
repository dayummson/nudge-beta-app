import 'package:flutter/material.dart';
import '../../../constants/categories.dart' as constants;

/// Manages a queue of notifications to prevent overlapping
class _NotificationQueue {
  static final List<_QueuedNotification> _queue = [];
  static bool _isShowing = false;

  static void add({
    required BuildContext context,
    required String categoryId,
    required double amount,
    required bool isExpense,
    required String action,
  }) {
    _queue.add(
      _QueuedNotification(
        context: context,
        categoryId: categoryId,
        amount: amount,
        isExpense: isExpense,
        action: action,
      ),
    );

    if (!_isShowing) {
      _showNext();
    }
  }

  static void _showNext() {
    if (_queue.isEmpty) {
      _isShowing = false;
      return;
    }

    _isShowing = true;
    final notification = _queue.removeAt(0);

    final overlay = Overlay.of(notification.context);
    late OverlayEntry overlayEntry;
    final animationKey = GlobalKey<_AnimatedNotificationState>();

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedNotification(
        key: animationKey,
        child: TransactionNotification(
          categoryId: notification.categoryId,
          amount: notification.amount,
          isExpense: notification.isExpense,
          action: notification.action,
        ),
        onDismiss: () {
          overlayEntry.remove();
          _showNext();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after 3 seconds with slide up animation
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted && animationKey.currentState != null) {
        animationKey.currentState!._slideUpAndRemove();
      }
    });
  }
}

class _QueuedNotification {
  final BuildContext context;
  final String categoryId;
  final double amount;
  final bool isExpense;
  final String action;

  _QueuedNotification({
    required this.context,
    required this.categoryId,
    required this.amount,
    required this.isExpense,
    required this.action,
  });
}

/// A custom notification widget for transaction operations (create/edit/delete).
/// Shows category icon, name, and amount in a compact rounded container.
class TransactionNotification extends StatefulWidget {
  final String categoryId;
  final double amount;
  final bool isExpense;
  final String action; // 'created', 'updated', 'deleted'

  const TransactionNotification({
    super.key,
    required this.categoryId,
    required this.amount,
    required this.isExpense,
    required this.action,
  });

  @override
  State<TransactionNotification> createState() =>
      _TransactionNotificationState();

  /// Shows the transaction notification as an overlay with slide animation
  static void show(
    BuildContext context, {
    required String categoryId,
    required double amount,
    required bool isExpense,
    required String action,
  }) {
    _NotificationQueue.add(
      context: context,
      categoryId: categoryId,
      amount: amount,
      isExpense: isExpense,
      action: action,
    );
  }
}

class _TransactionNotificationState extends State<TransactionNotification> {
  @override
  Widget build(BuildContext context) {
    final category = constants.categories.firstWhere(
      (c) => c.id == widget.categoryId,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category icon with colored background
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              category.icon,
              style: const TextStyle(
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Category name and action
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount in rounded container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isExpense
                  ? const Color(0xFFFF6B6B).withOpacity(0.12)
                  : const Color(0xFF58CC02).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${widget.isExpense ? '-' : '+'}₱${widget.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: widget.isExpense
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF58CC02),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedNotification extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismiss;

  const _AnimatedNotification({
    super.key,
    required this.child,
    required this.onDismiss,
  });

  @override
  State<_AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start above screen
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start the slide-in animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _slideUpAndRemove() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _slideUpAndRemove,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
