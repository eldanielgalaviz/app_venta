class Product {
  final int? id;
  final String name;
  final String sku;
  final double salePrice;
  final double costPrice;
  final int stock;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    required this.sku,
    required this.salePrice,
    required this.costPrice,
    required this.stock,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'sale_price': salePrice,
    'cost_price': costPrice,
    'stock': stock,
    'category_id': categoryId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as int?,
    name: json['name'] as String,
    sku: json['sku'] as String,
    salePrice: (json['sale_price'] as num).toDouble(),
    costPrice: (json['cost_price'] as num).toDouble(),
    stock: json['stock'] as int,
    categoryId: json['category_id'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Product copyWith({
    int? id,
    String? name,
    String? sku,
    double? salePrice,
    double? costPrice,
    int? stock,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    sku: sku ?? this.sku,
    salePrice: salePrice ?? this.salePrice,
    costPrice: costPrice ?? this.costPrice,
    stock: stock ?? this.stock,
    categoryId: categoryId ?? this.categoryId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
