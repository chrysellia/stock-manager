class ProductApiModel {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? category;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductApiModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.category,
    this.description,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductApiModel.fromJson(Map<String, dynamic> json) {
    return ProductApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      category: json['category'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String).toLocal() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }
}

// For the selection dialog
class ProductSelectionModel {
  final String id;
  final String name;
  final double price;
  final int quantity;

  ProductSelectionModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory ProductSelectionModel.fromJson(Map<String, dynamic> json) {
    return ProductSelectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}
