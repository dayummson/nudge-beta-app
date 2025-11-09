class Category {
  final String id;
  final String icon;
  final String name;
  final String? description;

  const Category({
    required this.id,
    required this.icon,
    required this.name,
    this.description,
  });
}
