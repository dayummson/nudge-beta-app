import "package:flutter/material.dart";
import 'dart:ui';
import 'toggle_mode.dart';

class Header extends StatelessWidget {
  final double blurSigma;
  final double overlayOpacity;
  final double totalAmount;
  final bool isExpense;
  final void Function(bool) toggleMode;

  const Header({
    super.key,
    required this.blurSigma,
    required this.overlayOpacity,
    required this.totalAmount,
    required this.isExpense,
    required this.toggleMode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Use colorScheme colors directly
    // final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            // apply the dynamic overlay opacity computed from scroll
            // convert to an alpha int to avoid the withOpacity deprecation
            // warning. Use the theme surface color so it adapts to light/dark
            // modes. Let the header size itself to its content so it hugs the
            // children and avoids hard-coded large heights that cause overflow.
            color: colorScheme.surface.withAlpha(
              (overlayOpacity * 255).clamp(0.0, 255.0).round(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title + settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Keep a small flexible spacer for layout; remove large
                      // visual placeholder used during prototyping.
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () {
                          // TODO: settings
                        },
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.settings,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Total in header (slightly smaller to save vertical space)
                  Text(
                    "Total: \$${totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Mode toggle (sliding) — size it to available width to avoid
                  // overflow on narrow devices.
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxW = constraints.maxWidth;
                      final toggleW = maxW.isFinite
                          ? (maxW * 0.5).clamp(120.0, 200.0)
                          : 180.0;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: ToggleMode(
                          isExpense: isExpense,
                          onChanged: (val) => toggleMode(val),
                          width: toggleW,
                          height: 50,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
