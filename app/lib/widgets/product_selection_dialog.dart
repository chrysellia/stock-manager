import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/product.dart';
import 'package:gestion_stock_epicerie/services/product_service.dart';

class ProductSelectionDialog extends StatefulWidget {
  final List<Product> selectedProducts;

  const ProductSelectionDialog({
    Key? key,
    required this.selectedProducts,
  }) : super(key: key);

  @override
  _ProductSelectionDialogState createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  final ProductService _productService = ProductService();
  final List<Product> _tempSelectedProducts = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Don't add existing products to temp selection - they're already in the invoice
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    try {
      final response = await _productService.getProductsForSelection();
      if (!mounted) return;

      setState(() {
        _allProducts = response;
        _filteredProducts = response;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur de chargement: $e';
        });
      }
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          final name = product['name']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery);
        }).toList();
      }
    });
  }

  bool _isProductAlreadyAdded(String productId) {
    // Check if product is already in the invoice (from widget.selectedProducts)
    return widget.selectedProducts.any((p) => p.id == productId);
  }

  bool _isProductTempSelected(String productId) {
    // Check if product is in temporary selection
    return _tempSelectedProducts.any((p) => p.id == productId);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ajouter des produits',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _filterProducts,
            ),
            const SizedBox(height: 16),

            // Selected products count
            if (_tempSelectedProducts.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_tempSelectedProducts.length} produit(s) sélectionné(s)',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Product list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadProducts,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _searchController.text.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.inventory_2_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? 'Aucun produit trouvé pour "${_searchController.text}"'
                                        : 'Aucun produit disponible',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: _filteredProducts.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                final isAlreadyAdded =
                                    _isProductAlreadyAdded(product['id']);
                                final isTempSelected =
                                    _isProductTempSelected(product['id']);
                                final quantity = product['quantity'] ?? 0;
                                final isOutOfStock = quantity <= 0;

                                return ListTile(
                                  enabled: !isAlreadyAdded && !isOutOfStock,
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isAlreadyAdded
                                          ? Colors.grey.withOpacity(0.3)
                                          : isOutOfStock
                                              ? Colors.red.withOpacity(0.1)
                                              : Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isAlreadyAdded
                                          ? Icons.check
                                          : isOutOfStock
                                              ? Icons.block
                                              : Icons.shopping_basket,
                                      size: 20,
                                      color: isAlreadyAdded
                                          ? Colors.grey
                                          : isOutOfStock
                                              ? Colors.red
                                              : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product['name'],
                                          maxLines: 1,
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                isAlreadyAdded || isOutOfStock
                                                    ? Colors.grey
                                                    : null,
                                            decoration: isAlreadyAdded
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                      if (isAlreadyAdded)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Déjà ajouté',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      if (isOutOfStock && !isAlreadyAdded)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Rupture',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          '${product['price']?.toStringAsFixed(0) ?? '0'} MGA',
                                          style: TextStyle(
                                            color:
                                                isAlreadyAdded || isOutOfStock
                                                    ? Colors.grey
                                                    : Theme.of(context)
                                                        .primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.inventory,
                                          size: 14,
                                          color: quantity > 10
                                              ? Colors.green
                                              : quantity > 0
                                                  ? Colors.orange
                                                  : Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Stock: $quantity',
                                            maxLines: 1,
                                            style: TextStyle(
                                              overflow: TextOverflow.fade,
                                              fontSize: 12,
                                              color: quantity > 10
                                                  ? Colors.green
                                                  : quantity > 0
                                                      ? Colors.orange
                                                      : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: !isAlreadyAdded && !isOutOfStock
                                      ? Checkbox(
                                          value: isTempSelected,
                                          onChanged: (bool? selected) {
                                            setState(() {
                                              if (selected == true) {
                                                _tempSelectedProducts
                                                    .add(Product(
                                                  id: product['id'],
                                                  name: product['name'],
                                                  price: product['price'],
                                                  quantity:
                                                      product['quantity'] ?? 0,
                                                ));
                                              } else {
                                                _tempSelectedProducts
                                                    .removeWhere(
                                                  (p) => p.id == product['id'],
                                                );
                                              }
                                            });
                                          },
                                        )
                                      : null,
                                  onTap: !isAlreadyAdded && !isOutOfStock
                                      ? () {
                                          setState(() {
                                            if (isTempSelected) {
                                              _tempSelectedProducts.removeWhere(
                                                (p) => p.id == product['id'],
                                              );
                                            } else {
                                              _tempSelectedProducts.add(Product(
                                                id: product['id'],
                                                name: product['name'],
                                                price: product['price'],
                                                quantity:
                                                    product['quantity'] ?? 0,
                                              ));
                                            }
                                          });
                                        }
                                      : null,
                                );
                              },
                            ),
            ),

            // Action buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _tempSelectedProducts.isEmpty
                        ? null
                        : () =>
                            Navigator.of(context).pop(_tempSelectedProducts),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _tempSelectedProducts.isEmpty
                          ? 'Ajouter'
                          : 'Ajouter (${_tempSelectedProducts.length})',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
