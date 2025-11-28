class TransactionUser {
  final String id; // userId
  final String status; // "pending" | "paid" | "requested"

  const TransactionUser({required this.id, required this.status});
}
