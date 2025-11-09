import 'package:flutter/material.dart';
import '../../room/domain/entities/expense.dart';

class TransactionsList extends StatelessWidget {
  final List<Expense> expenses;
  final Color miniTextColor;
  final double totalAmount;

  const TransactionsList({
    super.key,
    required this.expenses,
    required this.miniTextColor,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini total (tiny text for context while scrolling)
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 20),
          child: Text(
            "Total: \$${totalAmount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 12, color: miniTextColor),
          ),
        ),

        // Vertical list of items
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return ListTile(
              leading: Text(
                expense.category.icon,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                expense.title,

                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              subtitle: expense.description.isNotEmpty
                  ? Text(
                      expense.description,
                      style: TextStyle(
                        color: miniTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "\$${expense.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),

        // Bottom padding to prevent overlap with floating action buttons
        const SizedBox(height: 100),
      ],
    );
  }
}
