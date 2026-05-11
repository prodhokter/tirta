class Category {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? color;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.color,
  });
}
