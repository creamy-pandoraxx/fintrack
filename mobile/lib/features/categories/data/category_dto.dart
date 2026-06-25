import '../domain/category.dart';

class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    this.icon,
    this.color,
  });

  final String id;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final bool isDefault;

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isDefault: (json['isDefault'] as bool?) ?? false,
    );
  }

  Category toDomain() {
    return Category(
      id: id,
      name: name,
      type: CategoryType.fromApiValue(type),
      icon: icon,
      color: color,
      isDefault: isDefault,
    );
  }
}
