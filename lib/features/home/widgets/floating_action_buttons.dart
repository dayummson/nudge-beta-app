import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/search_enabled_provider.dart';
import '../presentation/pages/voice_page.dart';
import 'add_transaction_sheet.dart';

class FloatingActionButtons extends ConsumerStatefulWidget {
  final VoidCallback? onRoomChanged;

  const FloatingActionButtons({super.key, this.onRoomChanged});

  @override
  ConsumerState<FloatingActionButtons> createState() =>
      _FloatingActionButtonsState();
}

class _FloatingActionButtonsState extends ConsumerState<FloatingActionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() => ref.read(searchEnabledProvider.notifier).toggle();

  void _showAddTransactionSheet() {
    showAddTransactionSheet(context, onRoomChanged: widget.onRoomChanged);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final searchEnabled = ref.watch(searchEnabledProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.02;

    if (searchEnabled) {
      _animationController.forward();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _searchFocusNode.requestFocus(),
      );
    } else {
      _animationController.reverse();
    }

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: searchEnabled ? horizontalPadding : -400,
          right: horizontalPadding,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey[800]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Icon(Icons.search, color: colorScheme.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search transactions...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleSearch,
                        icon: Icon(Icons.close, color: colorScheme.onSurface),
                        padding: const EdgeInsets.all(8),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: searchEnabled ? -200 : horizontalPadding,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FadeTransition(
                opacity: ReverseAnimation(_fadeAnimation),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.onSurface.withOpacity(0.2),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _showAddTransactionSheet,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.add, size: 20),
                          ),
                        ),
                        InkWell(
                          onTap: _toggleSearch,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.search, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: searchEnabled ? -100 : horizontalPadding,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FadeTransition(
                opacity: ReverseAnimation(_fadeAnimation),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const VoicePage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                        transitionDuration: const Duration(milliseconds: 200),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFFEF5350),
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.mic, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
