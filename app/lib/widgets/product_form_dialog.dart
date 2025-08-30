import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/product.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({
    super.key,
    this.product,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _categoryController;
  // late TextEditingController _barcodeController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _alertThresholdController;

  String? _selectedCategory;
  final List<String> _categories = [
    'Alimentation',
    'Boissons',
    'Produits frais',
    'Surgelés',
    'Entretien',
    'Hygiène',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController =
        TextEditingController(text: product?.description ?? '');
    _priceController =
        TextEditingController(text: product?.price.toStringAsFixed(2) ?? '');
    _quantityController =
        TextEditingController(text: product?.quantity.toString() ?? '0');
    _categoryController = TextEditingController(
        text: product?.category.isNotEmpty == true ? product!.category : null);
    // _barcodeController = TextEditingController(text: product?.barcode ?? '');
    _purchasePriceController = TextEditingController(
        text: product?.purchasePrice?.toStringAsFixed(2) ?? '');
    _alertThresholdController =
        TextEditingController(text: product?.alertThreshold.toString() ?? '10');
    _selectedCategory = product?.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    // _barcodeController.dispose();
    _purchasePriceController.dispose();
    _alertThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
      title: Text(
          widget.product == null ? 'Nouveau produit' : 'Modifier le produit'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image du produit (placeholder pour l'instant)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 30),
                        SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            'Ajouter une image',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nom du produit
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du produit *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Catégorie
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une catégorie';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Prix et quantité
                Row(
                  children: [
                    // Prix de vente
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prix de vente *',
                          prefixText: '€ ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requis';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Prix invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Quantité
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantité *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requis';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Quantité invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // // Code-barres
                // TextFormField(
                //   controller: _barcodeController,
                //   decoration: const InputDecoration(
                //     labelText: 'Code-barres',
                //     border: OutlineInputBorder(),
                //   ),
                //   keyboardType: TextInputType.number,
                // ),
                // const SizedBox(height: 12),

                // Prix d'achat et seuil d'alerte
                Row(
                  children: [
                    // Prix d'achat
                    Expanded(
                      child: TextFormField(
                        controller: _purchasePriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prix d\'achat',
                          prefixText: '€ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Seuil d'alerte
                    Expanded(
                      child: TextFormField(
                        controller: _alertThresholdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Seuil d\'alerte',
                          border: OutlineInputBorder(),
                          // helperText: 'Stock bas',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    // TODO: Implémenter la sélection d'image
    // Pour l'instant, on ne fait rien
  }

  void _saveProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        quantity: int.parse(_quantityController.text),
        category: _selectedCategory ?? _categories.first,
        // barcode: _barcodeController.text.trim().isNotEmpty
        //     ? _barcodeController.text.trim()
        //     : null,
        purchasePrice: _purchasePriceController.text.isNotEmpty
            ? double.parse(_purchasePriceController.text.replaceAll(',', '.'))
            : null,
        alertThreshold: int.tryParse(_alertThresholdController.text) ?? 10,
      );

      Navigator.of(context).pop(product);
    }
  }
}
