import "package:flutter/material.dart";
import 'dart:ui';
import 'toggle_mode.dart';
import '../../../components/sheet/bottom_sheet_helper.dart';

class Header extends StatelessWidget {
  final double blurSigma;
  final double overlayOpacity;
  final double totalAmount;
  final bool isExpense;
  final void Function(bool) toggleMode;
  // Optional debug overrides (null in normal mode)
  final double? debugBlurOverride;
  final Color? debugOverlayColor;

  const Header({
    super.key,
    required this.blurSigma,
    required this.overlayOpacity,
    required this.totalAmount,
    required this.isExpense,
    required this.toggleMode,
    this.debugBlurOverride,
    this.debugOverlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,

      child: Stack(
        children: [
          // Background layer with blur and fade
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [
                  Colors.black, // Solid at top
                  Colors.black, // Keep solid throughout header content
                  Colors.transparent, // Smooth fade at bottom
                ],
                stops: const [
                  0.0,
                  0.85, // Keep solid until 85% (after toggle mode)
                  1.0, // Smooth fade to transparent
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: debugBlurOverride ?? blurSigma,
                  sigmaY: debugBlurOverride ?? blurSigma,
                ),
                child: Container(
                  color:
                      debugOverlayColor ??
                      colorScheme.surface.withOpacity(overlayOpacity),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          // Top row: title + settings
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(child: SizedBox()),
                              const SizedBox(
                                width: 20,
                                height: 20,
                              ), // Placeholder for alignment
                            ],
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 19), // Placeholder for total
                          const SizedBox(height: 8),
                          const SizedBox(height: 79), // Placeholder for toggle
                          const SizedBox(height: 12), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content layer (not affected by ShaderMask)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Top row: title + settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () => _showSettingsSheet(context),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.settings,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Total in header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              border: Border.all(
                                color: colorScheme.onSurface.withOpacity(0.2),
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '-',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            totalAmount.toStringAsFixed(2),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Toggle with fade section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxW = constraints.maxWidth;
                        final toggleW = maxW.isFinite
                            ? (maxW * 0.9).clamp(140.0, 200.0)
                            : 180.0;
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: ToggleMode(
                            isExpense: isExpense,
                            onChanged: (val) => toggleMode(val),
                            width: toggleW,
                            height: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Settings',

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to notifications
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to theme settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
