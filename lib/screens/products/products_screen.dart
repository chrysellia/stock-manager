import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/product.dart';
import 'package:gestion_stock_epicerie/services/product_service.dart';
import 'package:gestion_stock_epicerie/widgets/product_form_dialog.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productService.getAll();
      setState(() {
        _products = products;
        _filteredProducts = _filterProducts(products, _searchQuery);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des produits: $e')),
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
      _filteredProducts = _filterProducts(_products, _searchQuery);
    });
  }

  List<Product> _filterProducts(List<Product> products, String query) {
    if (query.isEmpty) return products;

    final lowercaseQuery = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          (product.barcode?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (product.description?.toLowerCase().contains(lowercaseQuery) ??
              false);
    }).toList();
  }

  Future<void> _showAddProductDialog() async {
    final result = await showDialog<Product>(
      context: context,
      builder: (context) => const ProductFormDialog(),
    );

    if (result != null && mounted) {
      await _saveProduct(result);
    }
  }

  Future<void> _showEditProductDialog(Product product) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );

    if (result != null && mounted) {
      await _saveProduct(result);
    }
  }

  Future<void> _saveProduct(Product product) async {
    try {
      await _productService.save(product);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit enregistré avec succès')),
        );
        _loadProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer le produit "${product.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _productService.delete(product.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produit supprimé avec succès')),
          );
          _loadProducts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Rafraîchir',
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
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Liste des produits
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Aucun produit trouvé. Commencez par en ajouter un !'
                              : 'Aucun produit ne correspond à votre recherche.',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                child: const Icon(Icons.inventory_2_outlined,
                                    color: Colors.blueGrey),
                              ),
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Catégorie: ${product.category}'),
                                  Text('Quantité: ${product.quantity}'),
                                  Text(
                                    '${product.price.toStringAsFixed(2)} €',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showEditProductDialog(product),
                                    tooltip: 'Modifier',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteProduct(product),
                                    tooltip: 'Supprimer',
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Optionnel: Afficher plus de détails sur le produit
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un produit'),
      ),
    );
  }
}
