import 'dart:async';

import 'package:gestion_stock_epicerie/models/stock.dart';
import 'package:gestion_stock_epicerie/services/crud_service.dart';

class StockService extends CrudService<StockMovement> {
  StockService()
      : super(
          collectionName: 'stock_movements',
          fromJson: (json) => StockMovement.fromJson(json),
        );

  // Récupérer l'historique des mouvements d'un produit
  Future<List<StockMovement>> getProductHistory(String productId) async {
    final movements = await getAll();
    return movements
        .where((movement) => movement.productId == productId)
        .toList()
      ..sort((a, b) => b.movementDate.compareTo(a.movementDate));
  }

  // Obtenir le stock actuel d'un produit
  Future<int> getCurrentStock(String productId) async {
    final movements = await getProductHistory(productId);
    return movements.fold(0, (sum, movement) {
      if (movement.isEntry || movement.isInitial) {
        return sum + movement.quantity;
      } else {
        return sum - movement.quantity;
      }
    });
  }

  // Enregistrer une entrée en stock
  Future<StockMovement> recordEntry({
    required String productId,
    required String productName,
    required int quantity,
    String? reference,
    String? notes,
    String? location,
    String? userId,
  }) async {
    final movement = StockMovement(
      productId: productId,
      productName: productName,
      quantity: quantity,
      type: StockMovementType.entry,
      movementDate: DateTime.now(),
      reference: reference,
      notes: notes,
      location: location,
      userId: userId,
    );

    return await save(movement);
  }

  // Enregistrer une sortie de stock
  Future<StockMovement> recordExit({
    required String productId,
    required String productName,
    required int quantity,
    String? reference,
    String? notes,
    String? location,
    String? userId,
  }) async {
    final currentStock = await getCurrentStock(productId);
    if (quantity > currentStock) {
      throw Exception('Stock insuffisant. Stock disponible: $currentStock');
    }

    final movement = StockMovement(
      productId: productId,
      productName: productName,
      quantity: quantity,
      type: StockMovementType.exit,
      movementDate: DateTime.now(),
      reference: reference,
      notes: notes,
      location: location,
      userId: userId,
    );

    return await save(movement);
  }

  // Effectuer un ajustement de stock
  Future<StockMovement> adjustStock({
    required String productId,
    required String productName,
    required int newQuantity,
    String? reason,
    String? location,
    String? userId,
  }) async {
    final currentStock = await getCurrentStock(productId);
    final difference = newQuantity - currentStock;
    final type =
        difference > 0 ? StockMovementType.adjustment : StockMovementType.exit;

    final movement = StockMovement(
      productId: productId,
      productName: productName,
      quantity: difference.abs(),
      type: type,
      movementDate: DateTime.now(),
      notes: reason ?? 'Ajustement de stock. Nouvelle quantité: $newQuantity',
      location: location,
      userId: userId,
    );

    return await save(movement);
  }

  // Obtenir les mouvements récents
  Future<List<StockMovement>> getRecentMovements({int limit = 50}) async {
    final movements = await getAll();
    movements.sort((a, b) => b.movementDate.compareTo(a.movementDate));
    return movements.take(limit).toList();
  }

  // Vérifier les stocks bas
  Future<List<Map<String, dynamic>>> getLowStockProducts(
      {int threshold = 10}) async {
    final movements = await getAll();
    final Map<String, List<StockMovement>> productMovements = {};
    final List<Map<String, dynamic>> lowStockProducts = [];

    // Grouper les mouvements par produit
    for (var movement in movements) {
      if (!productMovements.containsKey(movement.productId)) {
        productMovements[movement.productId] = [];
      }
      productMovements[movement.productId]!.add(movement);
    }

    // Calculer le stock actuel pour chaque produit
    for (var entry in productMovements.entries) {
      final productId = entry.key;
      final productMovements = entry.value;

      int currentStock = 0;
      String? productName;

      for (var movement in productMovements) {
        productName ??= movement.productName;
        if (movement.isEntry || movement.isInitial) {
          currentStock += movement.quantity;
        } else {
          currentStock -= movement.quantity;
        }
      }

      if (currentStock <= threshold) {
        lowStockProducts.add({
          'productId': productId,
          'productName': productName,
          'currentStock': currentStock,
        });
      }
    }

    return lowStockProducts;
  }

  Future<void> update(StockMovement movement) async {}
}

extension on FutureOr<int> {
  FutureOr<int> operator +(int other) async {
    final value = await this;
    return value + other;
  }

  FutureOr<int> operator -(int other) async {
    final value = await this;
    return value - other;
  }
}
