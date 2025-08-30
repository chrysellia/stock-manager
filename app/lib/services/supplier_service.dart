import 'package:gestion_stock_epicerie/models/supplier.dart';
import 'package:gestion_stock_epicerie/services/crud_service.dart';

class SupplierService extends CrudService<Supplier> {
  SupplierService()
      : super(
          collectionName: 'suppliers',
          fromJson: (json) => Supplier.fromJson(json),
        );

  // Récupérer les fournisseurs actifs
  Future<List<Supplier>> getActiveSuppliers() async {
    final suppliers = await getAll();
    return suppliers.where((s) => s.isActive).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  // Rechercher des fournisseurs par nom ou informations de contact
  Future<List<Supplier>> searchSuppliers(String query) async {
    if (query.isEmpty) return getActiveSuppliers();

    final lowercaseQuery = query.toLowerCase();
    final suppliers = await getAll();

    return suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(lowercaseQuery) ||
          (supplier.email?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (supplier.phone?.contains(query) ?? false) ||
          (supplier.taxNumber?.toLowerCase().contains(lowercaseQuery) ??
              false) ||
          (supplier.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  // Désactiver un fournisseur (soft delete)
  Future<void> deactivate(String id) async {
    try {
      final supplier = await getById(id);
      if (supplier != null) {
        await save(supplier.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        ));
      }
    } catch (e) {
      throw Exception('Erreur lors de la désactivation du fournisseur: $e');
    }
  }

  // Réactiver un fournisseur
  Future<void> reactivate(String id) async {
    try {
      final supplier = await getById(id);
      if (supplier != null) {
        await save(supplier.copyWith(
          isActive: true,
          updatedAt: DateTime.now(),
        ));
      }
    } catch (e) {
      throw Exception('Erreur lors de la réactivation du fournisseur: $e');
    }
  }

  // Vérifier si un fournisseur existe déjà avec le même nom
  Future<bool> existsWithName(String name, {String? excludeId}) async {
    final suppliers = await getAll();
    return suppliers.any((s) =>
        s.name.toLowerCase() == name.toLowerCase() &&
        (excludeId == null || s.id != excludeId));
  }

  // Obtenir le nombre total de fournisseurs actifs
  Future<int> getActiveSuppliersCount() async {
    final suppliers = await getAll();
    return suppliers.where((s) => s.isActive).length;
  }

  // Obtenir les fournisseurs récemment ajoutés ou modifiés
  Future<List<Supplier>> getRecentSuppliers({int limit = 10}) async {
    final suppliers = await getAll();
    suppliers.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    return suppliers.take(limit).toList();
  }

  // Mettre à jour les informations d'un fournisseur
  @override
  Future<Supplier> update(Supplier item) async {
    // Mettre à jour la date de mise à jour
    final updatedItem = item.copyWith(updatedAt: DateTime.now());
    return await save(updatedItem);
  }
}
