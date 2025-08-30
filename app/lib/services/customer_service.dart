import 'package:gestion_stock_epicerie/models/customer.dart';
import 'package:gestion_stock_epicerie/services/crud_service.dart';

class CustomerService extends CrudService<Customer> {
  CustomerService()
      : super(
          collectionName: 'customers',
          fromJson: (json) => Customer.fromJson(json),
        );

  // Get active customers
  Future<List<Customer>> getActiveCustomers() async {
    final customers = await getAll();
    return customers
        .where((c) => c.isActive)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
          (customer.taxNumber?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (customer.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  // Deactivate a customer (soft delete)
  Future<void> deactivate(String id) async {
    try {
      final customer = await getById(id);
      if (customer != null) {
        await save(customer.copyWith(
          isActive: false,
          // updatedAt: DateTime.now(),
        ));
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
        await save(customer.copyWith(
          currentCredit: newCredit,
          // updatedAt: DateTime.now(),
        ));
      }
    } catch (e) {
      throw Exception('Error updating customer credit: $e');
    }
  }

  // Get customers with negative balance
  Future<List<Customer>> getCustomersWithNegativeBalance() async {
    final customers = await getActiveCustomers();
    return customers
        .where((c) => (c.currentCredit ?? 0) < 0)
        .toList()
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
