import 'package:gestion_stock_epicerie/models/base_model.dart';

enum StockMovementType { entry, exit, adjustment, transfer, initial }

class StockMovement extends BaseModel {
  final String productId;
  final String productName;
  final int quantity;
  final StockMovementType type;
  final DateTime movementDate;
  final String? reference; // Numéro de facture, bon de livraison, etc.
  final String? notes;
  final String? location; // Emplacement du stock (entrepôt, rayon, etc.)
  final String? userId; // Utilisateur ayant effectué le mouvement

  StockMovement({
    String? id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.type,
    required this.movementDate,
    this.reference,
    this.notes,
    this.location,
    this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  // Créer un mouvement de stock à partir d'un JSON
  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      type: StockMovementType.values.firstWhere(
        (e) => e.toString() == 'StockMovementType.${json['type']}',
        orElse: () => StockMovementType.entry,
      ),
      movementDate: DateTime.parse(json['movementDate']),
      reference: json['reference'],
      notes: json['notes'],
      location: json['location'],
      userId: json['userId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Convertir le mouvement de stock en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'type': type.toString().split('.').last,
      'movementDate': movementDate.toIso8601String(),
      'reference': reference,
      'notes': notes,
      'location': location,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Créer une copie du mouvement avec des valeurs mises à jour
  StockMovement copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    StockMovementType? type,
    DateTime? movementDate,
    String? reference,
    String? notes,
    String? location,
    String? userId,
  }) {
    return StockMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      movementDate: movementDate ?? this.movementDate,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      userId: userId ?? this.userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Méthodes utilitaires
  bool get isEntry => type == StockMovementType.entry;
  bool get isExit => type == StockMovementType.exit;
  bool get isAdjustment => type == StockMovementType.adjustment;
  bool get isTransfer => type == StockMovementType.transfer;
  bool get isInitial => type == StockMovementType.initial;

  // Obtenir le type de mouvement sous forme de chaîne lisible
  String get typeLabel {
    switch (type) {
      case StockMovementType.entry:
        return 'Entrée en stock';
      case StockMovementType.exit:
        return 'Sortie de stock';
      case StockMovementType.adjustment:
        return 'Ajustement de stock';
      case StockMovementType.transfer:
        return 'Transfert de stock';
      case StockMovementType.initial:
        return 'Stock initial';
    }
  }
}
