class ExpenseUser {
  final String id; // userId
  final String status; // "pending" | "paid" | "requested"

  const ExpenseUser({required this.id, required this.status});
}
