import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/search_enabled_provider.dart';
import '../../../constants/categories.dart' as constants;

class CategoriesList extends ConsumerWidget {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchEnabled = ref.watch(searchEnabledProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: searchEnabled ? 0 : 60,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: searchEnabled ? 0 : 1,
        child: searchEnabled
            ? const SizedBox.shrink()
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: constants.categories.length,
                itemBuilder: (context, index) {
                  final category = constants.categories[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(fontSize: 22, height: 1.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
