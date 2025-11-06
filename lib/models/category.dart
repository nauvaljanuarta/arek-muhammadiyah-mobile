class Category {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'No Name',
        description: json['description'] ?? '',
        icon: json['icon'] ?? 'circle',
        color: json['color'] ?? '#10B981',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'color': color,
      };
}
