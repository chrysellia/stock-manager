import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/supplier.dart';
import 'package:gestion_stock_epicerie/screens/suppliers/supplier_form_screen.dart';
import 'package:gestion_stock_epicerie/services/supplier_service.dart';
import 'package:gestion_stock_epicerie/theme/app_theme.dart';
import 'package:gestion_stock_epicerie/widgets/confirmation_dialog.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final SupplierService _supplierService = SupplierService();
  final TextEditingController _searchController = TextEditingController();

  List<Supplier> _suppliers = [];
  List<Supplier> _filteredSuppliers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoading = true);
    try {
      final suppliers = await _supplierService.getAll();
      setState(() {
        _suppliers = suppliers;
        _filteredSuppliers = _filterSuppliers(suppliers, _searchQuery);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors du chargement des fournisseurs: $e')),
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
      _filteredSuppliers = _filterSuppliers(_suppliers, _searchQuery);
    });
  }

  List<Supplier> _filterSuppliers(List<Supplier> suppliers, String query) {
    var filtered = suppliers.where((supplier) {
      if (!_showInactive && !supplier.isActive) return false;
      if (query.isEmpty) return true;

      final lowercaseQuery = query.toLowerCase();
      return supplier.name.toLowerCase().contains(lowercaseQuery) ||
          (supplier.email?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (supplier.phone?.contains(query) ?? false) ||
          (supplier.taxNumber?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();

    filtered
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return filtered;
  }

  Future<void> _toggleSupplierStatus(Supplier supplier) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Confirmer la modification',
      content:
          'Voulez-vous vraiment ${supplier.isActive ? 'désactiver' : 'réactiver'} ce fournisseur ?',
      confirmText: supplier.isActive ? 'Désactiver' : 'Réactiver',
      cancelText: 'Annuler',
    );

    if (confirmed == true) {
      try {
        if (supplier.isActive) {
          await _supplierService.deactivate(supplier.id!);
        } else {
          await _supplierService.reactivate(supplier.id!);
        }
        await _loadSuppliers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Fournisseur ${supplier.isActive ? 'désactivé' : 'réactivé'} avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à jour du statut: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Supprimer le fournisseur',
      content:
          'Êtes-vous sûr de vouloir supprimer définitivement ce fournisseur ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      confirmColor: Colors.red,
    );

    if (confirmed == true) {
      try {
        await _supplierService.delete(supplier.id!);
        await _loadSuppliers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fournisseur supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fournisseurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSuppliers,
            tooltip: 'Rafraîchir',
          ),
          PopupMenuButton<bool>(
            onSelected: (value) {
              setState(() => _showInactive = value);
              _onSearchChanged();
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: true,
                checked: _showInactive,
                child: const Text('Afficher les fournisseurs inactifs'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un fournisseur...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),

          // Liste des fournisseurs
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSuppliers.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Aucun fournisseur trouvé.\nCommencez par ajouter un fournisseur.'
                              : 'Aucun fournisseur ne correspond à votre recherche.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredSuppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = _filteredSuppliers[index];
                          return _buildSupplierCard(supplier);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Supplier>(
            context,
            MaterialPageRoute(
              builder: (context) => const SupplierFormScreen(),
            ),
          );

          if (result != null && mounted) {
            await _loadSuppliers();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSupplierCard(Supplier supplier) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: supplier.isActive ? null : Colors.grey[100],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: supplier.isActive
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[300],
          child: Icon(
            supplier.isActive ? Icons.business : Icons.business_outlined,
            color: supplier.isActive
                ? Theme.of(context).primaryColor
                : Colors.grey[600],
          ),
        ),
        title: Text(
          supplier.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: supplier.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supplier.phone != null) Text('Tél: ${supplier.phone}'),
            if (supplier.email != null) Text('Email: ${supplier.email}'),
            if (supplier.formattedAddress != null)
              Text(supplier.formattedAddress!),
            if (!supplier.isActive)
              const Text(
                'Inactif',
                style: TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                final result = await Navigator.push<Supplier>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SupplierFormScreen(supplier: supplier),
                  ),
                );
                if (result != null && mounted) {
                  await _loadSuppliers();
                }
                break;
              case 'toggle_status':
                await _toggleSupplierStatus(supplier);
                break;
              case 'delete':
                await _deleteSupplier(supplier);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Modifier'),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: Text(supplier.isActive ? 'Désactiver' : 'Réactiver'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        onTap: () {
          // TODO: Afficher les détails du fournisseur
        },
      ),
    );
  }
}
