import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/customer.dart';
import 'package:gestion_stock_epicerie/screens/customers/customer_form_screen.dart';
import 'package:gestion_stock_epicerie/services/customer_service.dart';
import 'package:gestion_stock_epicerie/widgets/confirmation_dialog.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerService _customerService = CustomerService();
  final TextEditingController _searchController = TextEditingController();

  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await _customerService.getAll();
      setState(() {
        _customers = customers;
        _filteredCustomers = _filterCustomers(customers, _searchQuery);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des clients: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filteredCustomers = _filterCustomers(_customers, _searchQuery);
    });
  }

  List<Customer> _filterCustomers(List<Customer> customers, String query) {
    if (query.isEmpty) {
      return customers.where((c) => _showInactive || c.isActive).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return customers.where((customer) {
      final matchesSearch = customer.name
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          (customer.email?.toLowerCase().contains(query.toLowerCase()) ??
              false) ||
          (customer.phone?.contains(query) ?? false) ||
          (customer.taxNumber?.toLowerCase().contains(query.toLowerCase()) ??
              false);

      return matchesSearch && (_showInactive || customer.isActive);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> _toggleCustomerStatus(Customer customer) async {
    try {
      await _customerService.update(
        customer.copyWith(
          isActive: !customer.isActive,
          // updatedAt: DateTime.now(),
        ),
      );
      await _loadCustomers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la mise à jour du client: $e')),
        );
      }
    }
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Supprimer le client',
        content:
            'Êtes-vous sûr de vouloir supprimer définitivement ce client ? Cette action est irréversible.',
        confirmText: 'Supprimer',
      ),
    );

    if (confirmed == true) {
      try {
        await _customerService.delete(customer.id!);
        if (mounted) {
          await _loadCustomers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erreur lors de la suppression du client: $e')),
          );
        }
      }
    }
  }

  Future<void> _navigateToCustomerForm({Customer? customer}) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormScreen(customer: customer),
      ),
    );

    // Refresh the list if:
    // 1. A customer was returned (created/updated)
    // 2. A boolean true was returned (deleted)
    // 3. Any other truthy value was returned
    if (result != null) {
      await _loadCustomers();

      // Show success message based on the operation
      if (mounted) {
        String message;
        if (result is Customer) {
          message = customer == null
              ? 'Client créé avec succès'
              : 'Client modifié avec succès';
        } else if (result == true) {
          message = 'Client supprimé avec succès';
        } else {
          message = 'Opération effectuée avec succès';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un client...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _showInactive ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showInactive = !_showInactive;
                      _filteredCustomers =
                          _filterCustomers(_customers, _searchQuery);
                    });
                  },
                  tooltip: _showInactive
                      ? 'Masquer les clients inactifs'
                      : 'Afficher les clients inactifs',
                ),
              ],
            ),
          ),
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _filteredCustomers.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Aucun client trouvé'
                                  : 'Aucun client ne correspond à votre recherche',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Appuyez sur + pour ajouter votre premier client',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadCustomers,
                        child: ListView.builder(
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            return _buildCustomerCard(customer);
                          },
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCustomerForm(),
        tooltip: 'Ajouter un client',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                customer.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: customer.isActive ? null : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!customer.isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Inactif',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone != null) Text('Tél: ${customer.phone}'),
            if (customer.email != null) Text('Email: ${customer.email}'),
            if (customer.city != null) Text('Ville: ${customer.city}'),
            if (customer.creditLimit != null)
              Text(
                'Limite de crédit: ${customer.creditLimit!.toStringAsFixed(0)} MGA',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            if (customer.currentCredit != null && customer.currentCredit != 0)
              Text(
                'Crédit actuel: ${customer.currentCredit!.toStringAsFixed(0)} MGA',
                style: TextStyle(
                  color: (customer.currentCredit ?? 0) < 0
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                await _navigateToCustomerForm(customer: customer);
                break;
              case 'toggle_status':
                await _toggleCustomerStatus(customer);
                break;
              case 'delete':
                await _deleteCustomer(customer);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(
                    customer.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(customer.isActive ? 'Désactiver' : 'Activer'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _navigateToCustomerForm(customer: customer),
      ),
    );
  }
}
