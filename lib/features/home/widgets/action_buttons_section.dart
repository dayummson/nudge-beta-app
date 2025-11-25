import 'package:flutter/material.dart';

class ActionButtonsSection extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback? onHashtag;
  final bool isExpanded;
  final List<String> hashtags;
  final TextEditingController? hashtagController;
  final ValueChanged<String>? onHashtagSubmit;
  final VoidCallback? onCollapse;

  const ActionButtonsSection({
    super.key,
    required this.isSaving,
    required this.onSave,
    this.onHashtag,
    this.isExpanded = false,
    this.hashtags = const [],
    this.hashtagController,
    this.onHashtagSubmit,
    this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: isExpanded
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hashtagController,
                      decoration: InputDecoration(
                        hintText: 'Enter hashtag',
                        prefixIcon: hashtags.isNotEmpty
                            ? Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                children: hashtags
                                    .map(
                                      (tag) => Chip(
                                        label: Text(
                                          '#$tag',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    )
                                    .toList(),
                              )
                            : null,
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty && hashtags.length < 5) {
                          onHashtagSubmit?.call(value.trim());
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: onCollapse,
                  ),
                ],
              )
            : Row(
                children: [
                  OutlinedButton(
                    onPressed: onHashtag,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      fixedSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: isDark
                          ? Colors.grey[850]
                          : Colors.grey[300],
                      side: BorderSide.none,
                      foregroundColor: cs.onSurfaceVariant,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      hashtags.isEmpty ? '#' : '# ${hashtags.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSaving ? null : onSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: isSaving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.onPrimary,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
