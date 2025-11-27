import 'package:flutter/material.dart';

class ActionButtonsSection extends StatefulWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback? onHashtag;
  final bool isExpanded;
  final List<String> hashtags;
  final TextEditingController? hashtagController;
  final ValueChanged<String>? onHashtagSubmit;
  final VoidCallback? onCollapse;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onRemoveLast;
  final ValueChanged<String>? onRemoveHashtag;

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
    this.onDelete,
    this.onRemoveLast,
    this.onRemoveHashtag,
  });

  @override
  State<ActionButtonsSection> createState() => _ActionButtonsSectionState();
}

class _ActionButtonsSectionState extends State<ActionButtonsSection> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Padding(
        key: ValueKey(
          'action_buttons_${widget.hashtags.isNotEmpty || widget.isExpanded}',
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: (widget.hashtags.isNotEmpty || widget.isExpanded)
            ? Row(
                key: const ValueKey('expanded'),
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: widget.hashtagController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        hintText: 'Tag',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 4,
                            color: isDark
                                ? Colors.grey[850]!
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color.fromARGB(255, 67, 67, 67)
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[850]!
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color.fromARGB(255, 36, 36, 36)
                            : Colors.grey[300],
                        prefixIcon: widget.hashtags.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(6),
                                child: SizedBox(
                                  height: 32,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: widget.hashtags
                                          .map(
                                            (tag) => Padding(
                                              padding: const EdgeInsets.only(
                                                right: 4,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Allow tapping chips to edit them
                                                  if (widget
                                                          .hashtagController !=
                                                      null) {
                                                    widget.onRemoveHashtag
                                                        ?.call(tag);
                                                    widget
                                                            .hashtagController!
                                                            .text =
                                                        tag;
                                                    widget
                                                            .hashtagController!
                                                            .selection =
                                                        TextSelection.fromPosition(
                                                          TextPosition(
                                                            offset: tag.length,
                                                          ),
                                                        );
                                                  }
                                                },
                                                child: Chip(
                                                  label: Text(
                                                    '#$tag',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  deleteIcon: const Icon(
                                                    Icons.close,
                                                    size: 16,
                                                  ),
                                                  onDeleted: () {
                                                    widget.onRemoveHashtag
                                                        ?.call(tag);
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  side: BorderSide.none,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                        255,
                                                        52,
                                                        52,
                                                        52,
                                                      ),
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      onChanged: null,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty &&
                            widget.hashtags.length < 3) {
                          widget.onHashtagSubmit?.call(value.trim());
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    width: 48,

                    child: OutlinedButton(
                      onPressed: widget.onDelete,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Icon(Icons.delete),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    width: 48,

                    child: OutlinedButton(
                      onPressed: widget.hashtags.isNotEmpty
                          ? widget.onSave
                          : widget.onCollapse,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Icon(Icons.check),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  OutlinedButton(
                    onPressed: widget.onHashtag,
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
                      widget.hashtags.isEmpty
                          ? '#'
                          : '# ${widget.hashtags.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.isSaving ? null : widget.onSave,
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
                      child: widget.isSaving
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
