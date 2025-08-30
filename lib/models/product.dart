import 'package:gestion_stock_epicerie/models/base_model.dart';

class Product extends BaseModel {
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String category;
  final String? imageUrl;
  final String? barcode;
  final double? purchasePrice;
  final String? supplierId;
  final int alertThreshold;

  Product({
    String? id,
    required this.name,
    this.description = '',
    required this.price,
    this.quantity = 0,
    this.category = 'Non catégorisé',
    this.imageUrl,
    this.barcode,
    this.purchasePrice,
    this.supplierId,
    this.alertThreshold = 10,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  // Créer un produit à partir d'un JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] ?? 0,
      category: json['category'] ?? 'Non catégorisé',
      imageUrl: json['imageUrl'],
      barcode: json['barcode'],
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      supplierId: json['supplierId'],
      alertThreshold: json['alertThreshold'] ?? 10,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Convertir le produit en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'purchasePrice': purchasePrice,
      'supplierId': supplierId,
      'alertThreshold': alertThreshold,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Créer une copie du produit avec des valeurs mises à jour
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? quantity,
    String? category,
    String? imageUrl,
    String? barcode,
    double? purchasePrice,
    String? supplierId,
    int? alertThreshold,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      supplierId: supplierId ?? this.supplierId,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Vérifier si le stock est bas
  bool get isLowStock => quantity <= alertThreshold;

  // Calculer la valeur du stock
  double get stockValue => price * quantity;
}
