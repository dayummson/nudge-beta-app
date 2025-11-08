import "package:flutter/material.dart";
import 'dart:ui';
import 'toggle_mode.dart';

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
                // Top is solid throughout content area, fade only at bottom edge
                colors: const [
                  Colors.black, // Solid at top
                  Colors.black, // Keep solid throughout header content
                  Colors.black, // Solid until near bottom
                  Color(0xFC000000), // 99% opacity
                  Color(0xFA000000), // 98% opacity
                  Color(0xF5000000), // 96% opacity
                  Color(0xF0000000), // 94% opacity
                  Color(0xEB000000), // 92% opacity
                  Color(0xE6000000), // 90% opacity
                  Color(0xE0000000), // 88% opacity
                  Color(0xD9000000), // 85% opacity
                  Color(0xD1000000), // 82% opacity
                  Color(0xC9000000), // 79% opacity
                  Color(0xC0000000), // 75% opacity
                  Color(0xB3000000), // 70% opacity
                  Color(0xA6000000), // 65% opacity
                  Color(0x99000000), // 60% opacity
                  Color(0x80000000), // 50% opacity
                  Color(0x66000000), // 40% opacity
                  Color(0x4D000000), // 30% opacity
                  Color(0x33000000), // 20% opacity
                  Color(0x1A000000), // 10% opacity
                  Color(0x0D000000), // 5% opacity
                  Colors.transparent, // Fully transparent at bottom
                ],
                stops: const [
                  0.0,
                  0.85, // Keep solid until 85% (where SafeArea content ends)
                  0.88, // Start gentle fade
                  0.89,
                  0.90,
                  0.91,
                  0.92,
                  0.925,
                  0.93,
                  0.935,
                  0.94,
                  0.945,
                  0.95,
                  0.955,
                  0.96,
                  0.965,
                  0.97,
                  0.975,
                  0.98,
                  0.985,
                  0.99,
                  0.995,
                  0.998,
                  1.0,
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        // Solid at top with faint dark tint for contrast
                        colorScheme.surface.withOpacity(overlayOpacity),
                        colorScheme.surface.withOpacity(overlayOpacity),
                        Color.lerp(
                          colorScheme.surface,
                          Colors.black,
                          0.02,
                        )!.withOpacity(overlayOpacity * 0.98),
                        Color.lerp(
                          colorScheme.surface,
                          Colors.black,
                          0.03,
                        )!.withOpacity(overlayOpacity * 0.96),
                        Color.lerp(
                          colorScheme.surface,
                          Colors.black,
                          0.04,
                        )!.withOpacity(overlayOpacity * 0.92),
                        // Gentle fade starting around 80-90% (10% from bottom)
                        Color.lerp(
                          colorScheme.surface,
                          Colors.black,
                          0.04,
                        )!.withOpacity(overlayOpacity * 0.85),
                        Color.lerp(
                          colorScheme.surface,
                          Colors.black,
                          0.05,
                        )!.withOpacity(overlayOpacity * 0.70),
                        Color.lerp(
                          colorScheme.surface,
                          Colors.black,
                          0.05,
                        )!.withOpacity(overlayOpacity * 0.40),
                        Colors.transparent,
                      ],
                      stops: const [
                        0.0,
                        0.5,
                        0.65,
                        0.75,
                        0.82,
                        0.88,
                        0.93,
                        0.97,
                        1.0,
                      ],
                    ),
                  ),
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
                        onPressed: () {
                          // TODO: settings
                        },
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
}
