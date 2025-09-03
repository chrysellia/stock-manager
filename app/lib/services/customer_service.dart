import 'package:gestion_stock_epicerie/models/customer.dart';
import 'package:gestion_stock_epicerie/services/api_service.dart';

class CustomerService {
  final ApiService _apiService = ApiService();
  final String _endpoint = 'customers';

  // Get all customers
  Future<List<Customer>> getAll() async {
    try {
      final response = await _apiService.get(_endpoint);
      return (response as List).map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get a customer by ID
  Future<Customer> getById(String id) async {
    try {
      final response = await _apiService.get('$_endpoint/$id');
      return Customer.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Customer> save(Customer customer) async {
    try {
      final response = await _apiService.post(
        _endpoint,
        body: customer.toJson(forCreation: true),
      );
      return Customer.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Customer> update(Customer customer) async {
    try {
      await _apiService.put(
        '$_endpoint/${customer.id}',
        body: customer.toJson(),
      );
      return customer;
    } catch (e) {
      rethrow;
    }
  }

  // Delete a customer
  Future<void> delete(String id) async {
    try {
      await _apiService.delete('$_endpoint/$id');
    } catch (e) {
      rethrow;
    }
  }

  // Get active customers
  Future<List<Customer>> getActiveCustomers() async {
    try {
      final customers = await getAll();
      return customers.where((c) => c.isActive).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      rethrow;
    }
  }

  // Search customers by name or contact information
  Future<List<Customer>> searchCustomers(String query) async {
    if (query.isEmpty) return getActiveCustomers();

    final lowercaseQuery = query.toLowerCase();
    final customers = await getAll();

    return customers.where((customer) {
      return customer.name.toLowerCase().contains(lowercaseQuery) ||
          (customer.email?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (customer.phone?.contains(query) ?? false) ||
          (customer.taxNumber?.toLowerCase().contains(lowercaseQuery) ??
              false) ||
          (customer.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  // Deactivate a customer (soft delete)
  Future<void> deactivate(String id) async {
    try {
      final customer = await getById(id);
      if (customer != null) {
        await save(customer.copyWith(isActive: false));
      }
    } catch (e) {
      throw Exception('Error deactivating customer: $e');
    }
  }

  // Update customer credit
  Future<void> updateCredit(String customerId, double amount) async {
    try {
      final customer = await getById(customerId);
      if (customer != null) {
        final newCredit = (customer.currentCredit ?? 0) + amount;
        await save(customer.copyWith(currentCredit: newCredit));
      }
    } catch (e) {
      throw Exception('Error updating customer credit: $e');
    }
  }

  // Get customers with negative balance
  Future<List<Customer>> getCustomersWithNegativeBalance() async {
    final customers = await getActiveCustomers();
    return customers.where((c) => (c.currentCredit ?? 0) < 0).toList()
      ..sort((a, b) => (a.currentCredit ?? 0).compareTo(b.currentCredit ?? 0));
  }

  // Get customers with credit limit reached
  Future<List<Customer>> getCustomersWithCreditLimitReached() async {
    final customers = await getActiveCustomers();
    return customers
        .where((c) =>
            c.creditLimit != null &&
            (c.currentCredit ?? 0) >= (c.creditLimit ?? 0))
        .toList()
      ..sort((a, b) => (a.currentCredit ?? 0).compareTo(b.currentCredit ?? 0));
  }
}
