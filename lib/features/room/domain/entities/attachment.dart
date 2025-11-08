class Attachment {
  final String id;
  final String url;
  final String type;
  final String uploadedBy;
  final DateTime createdAt;
  final Map<String, int> reactionCounts;

  const Attachment({
    required this.id,
    required this.url,
    required this.type,
    required this.uploadedBy,
    required this.createdAt,
    required this.reactionCounts,
  });
}
