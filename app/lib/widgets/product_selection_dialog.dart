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
  final List<Product> _selectedProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedProducts.addAll(widget.selectedProducts);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    
    try {
      final response = await _productService.getProductsForSelection();
      if (!mounted) return;
      
      setState(() {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter des produits'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                : _buildProductList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _selectedProducts.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selectedProducts),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _productService.getProductsForSelection(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}', 
                style: const TextStyle(color: Colors.red)),
          );
        }

        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return const Center(child: Text('Aucun produit disponible'));
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isSelected = _selectedProducts.any((p) => p.id == product['id']);
            
            return CheckboxListTile(
              value: isSelected,
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _selectedProducts.add(Product(
                      id: product['id'],
                      name: product['name'],
                      price: product['price'],
                      quantity: product['quantity'] ?? 0,
                    ));
                  } else {
                    _selectedProducts.removeWhere((p) => p.id == product['id']);
                  }
                });
              },
              title: Text(product['name']),
              subtitle: Text('${product['price']?.toStringAsFixed(2) ?? '0.00'} €'),
            );
          },
        );
      },
    );
  }
}
