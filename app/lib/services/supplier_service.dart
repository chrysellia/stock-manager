import 'package:gestion_stock_epicerie/models/supplier.dart';
import 'package:gestion_stock_epicerie/services/api_service.dart';

class SupplierService {
  final ApiService _apiService = ApiService();
  final String _endpoint = 'suppliers';

  // Get all suppliers
  Future<List<Supplier>> getAll() async {
    try {
      final response = await _apiService.get(_endpoint);
      return (response as List).map((json) => Supplier.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get a supplier by ID
  Future<Supplier> getById(String id) async {
    try {
      final response = await _apiService.get('$_endpoint/$id');
      return Supplier.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Create a new supplier
  Future<Supplier> save(Supplier supplier) async {
    try {
      final response = await _apiService.post(
        _endpoint,
        body: supplier.toJson(forCreation: true),
      );
      return Supplier.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a supplier
  Future<void> delete(String id) async {
    try {
      await _apiService.delete('$_endpoint/$id');
    } catch (e) {
      rethrow;
    }
  }

  // Get active suppliers
  Future<List<Supplier>> getActiveSuppliers() async {
    try {
      final suppliers = await getAll();
      return suppliers.where((s) => s.isActive).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      rethrow;
    }
  }

  // Search suppliers by name or contact information
  Future<List<Supplier>> searchSuppliers(String query) async {
    if (query.isEmpty) return getActiveSuppliers();

    try {
      final lowercaseQuery = query.toLowerCase();
      final suppliers = await getAll();

      return suppliers.where((supplier) {
        return supplier.name.toLowerCase().contains(lowercaseQuery) ||
            (supplier.email?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (supplier.phone?.contains(query) ?? false) ||
            (supplier.taxNumber?.contains(query) ?? false);
      }).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      rethrow;
    }
  }

  // Désactiver un fournisseur (soft delete)
  Future<void> deactivate(String id) async {
    try {
      final supplier = await getById(id);
      if (supplier != null) {
        await save(supplier.copyWith(isActive: false));
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
        await save(supplier.copyWith(isActive: true));
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

  // Update an existing supplier
  @override
  Future<Supplier> update(Supplier supplier) async {
    try {
      await _apiService.put(
        '$_endpoint/${supplier.id}',
        body: supplier.toJson(),
      );
      return supplier;
    } catch (e) {
      rethrow;
    }
  }
}
