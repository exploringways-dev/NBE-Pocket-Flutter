class ApiCategory {
  const ApiCategory({
    required this.id,
    required this.name,
    this.mccCode,
    this.iconBase64,
  });

  final int id;
  final String name;
  final String? mccCode;
  final String? iconBase64;

  factory ApiCategory.fromJson(Map<String, dynamic> json) => ApiCategory(
        id: (json['id'] as num).toInt(),
        name: json['catName']?.toString() ?? '',
        mccCode: json['mccCode']?.toString(),
        iconBase64: json['iconBase64']?.toString(),
      );
}
