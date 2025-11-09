import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/search_enabled_provider.dart';
import '../presentation/pages/voice_page.dart';
import '../../../components/sheet/bottom_sheet_helper.dart';

class FloatingActionButtons extends ConsumerStatefulWidget {
  const FloatingActionButtons({super.key});

  @override
  ConsumerState<FloatingActionButtons> createState() =>
      _FloatingActionButtonsState();
}

class _FloatingActionButtonsState extends ConsumerState<FloatingActionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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

  void _closeSearch() {
    _searchFocusNode.unfocus();
    _searchController.clear();
    ref.read(searchEnabledProvider.notifier).setEnabled(false);
  }

  void _showAddTransactionSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Add Transaction',
      heightFactor: 0.6, // 80% of screen height
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items:
                  ['Food', 'Transport', 'Entertainment', 'Utilities', 'Health']
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                // TODO: Handle category selection
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Handle add transaction
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Add Transaction'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final searchEnabled = ref.watch(searchEnabledProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.02; // 2% of screen width

    // Animate based on search state
    if (searchEnabled) {
      _animationController.forward();
      // Auto-focus when search opens
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    } else {
      _animationController.reverse();
    }

    return Stack(
      children: [
        // Search bar (visible when searchEnabled is true)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: searchEnabled ? horizontalPadding : -400, // Slide in from left
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
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search transactions...',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            // TODO: Implement search logic
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _closeSearch,
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

        // Original floating buttons (visible when searchEnabled is false)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: searchEnabled ? -200 : horizontalPadding, // Slide out to left
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
                        // Add button
                        InkWell(
                          onTap: () => _showAddTransactionSheet(context),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.add,
                              color: colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                        // Search button
                        InkWell(
                          onTap: () {
                            ref.read(searchEnabledProvider.notifier).toggle();
                          },
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.search,
                              color: colorScheme.onSurface,
                              size: 20,
                            ),
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

        // Microphone button (always visible, moves to accommodate search bar)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: searchEnabled
              ? -100
              : horizontalPadding, // Hide when search is active
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
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 200),
                      ),
                    );
                  },
                  backgroundColor: Color(0xFFEF5350),
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
