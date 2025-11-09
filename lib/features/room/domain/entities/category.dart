class Category {
  final String id;
  final String icon;
  final String name;
  final String? description;
  final int color; // Color value as int

  const Category({
    required this.id,
    required this.icon,
    required this.name,
    this.description,
    required this.color,
  });
}
