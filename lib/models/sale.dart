class Sale {
  final int? id;
  final int userId;
  final int? customerId;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sale({
    this.id,
    required this.userId,
    this.customerId,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'customer_id': customerId,
    'subtotal': subtotal,
    'tax': tax,
    'total': total,
    'payment_method': paymentMethod,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
    id: json['id'] as int?,
    userId: json['user_id'] as int,
    customerId: json['customer_id'] as int?,
    subtotal: (json['subtotal'] as num).toDouble(),
    tax: (json['tax'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
    paymentMethod: json['payment_method'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Sale copyWith({
    int? id,
    int? userId,
    int? customerId,
    double? subtotal,
    double? tax,
    double? total,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Sale(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    customerId: customerId ?? this.customerId,
    subtotal: subtotal ?? this.subtotal,
    tax: tax ?? this.tax,
    total: total ?? this.total,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
