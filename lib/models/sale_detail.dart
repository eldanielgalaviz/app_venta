class SaleDetail {
  final int? id;
  final int saleId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  SaleDetail({
    this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sale_id': saleId,
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'unit_price': unitPrice,
    'subtotal': subtotal,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory SaleDetail.fromJson(Map<String, dynamic> json) => SaleDetail(
    id: json['id'] as int?,
    saleId: json['sale_id'] as int,
    productId: json['product_id'] as int,
    productName: json['product_name'] as String,
    quantity: json['quantity'] as int,
    unitPrice: (json['unit_price'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  SaleDetail copyWith({
    int? id,
    int? saleId,
    int? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SaleDetail(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    subtotal: subtotal ?? this.subtotal,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
