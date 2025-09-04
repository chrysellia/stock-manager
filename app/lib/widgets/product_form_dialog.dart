import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/product.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
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
    _purchasePriceController = TextEditingController(
        text: product?.purchasePrice?.toStringAsFixed(2) ?? '');
    _alertThresholdController =
        TextEditingController(text: product?.alertThreshold.toString() ?? '10');
    _selectedCategory = product?.category;
    
    // If editing a product with an existing image, show it
    if (product?.imageUrl != null && product!.imageUrl!.isNotEmpty) {
      _selectedImage = File(product.imageUrl!);
    }
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
                    child: _selectedImage == null
                        ? const Column(
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
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                  ),
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
                          prefixText: 'MGA ',
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
                          prefixText: 'MGA ',
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
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      try {
        final XFile? image = await _picker.pickImage(source: result);
        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de la sélection de l\'image')),
        );
      }
    }
  }

  void _saveProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // If we're editing an existing product and no new image was selected,
        // keep the existing image URL
        String? imageUrl = widget.product?.imageUrl;
        
        // If a new image was selected, use its path
        if (_selectedImage != null) {
          imageUrl = _selectedImage!.path;
        }
        
        // Helper function to parse double values safely
        double? parseDouble(String? value) {
          if (value == null || value.isEmpty) return null;
          // Remove any non-numeric characters except decimal point and comma
          final numericString = value.replaceAll(RegExp(r'[^0-9.,]'), '');
          // Replace comma with dot for proper parsing
          return double.tryParse(numericString.replaceAll(',', '.'));
        }
        
        // Parse purchase price safely
        final purchasePrice = parseDouble(_purchasePriceController.text);
        
        final product = Product(
          id: widget.product?.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: parseDouble(_priceController.text) ?? 0.0,
          quantity: int.tryParse(_quantityController.text) ?? 0,
          category: _selectedCategory ?? _categories.first,
          imageUrl: imageUrl,
          purchasePrice: purchasePrice ?? 0.0, // Ensure purchasePrice is never null
          alertThreshold: int.tryParse(_alertThresholdController.text) ?? 10,
        );

        if (!context.mounted) return;
        Navigator.of(context).pop(product);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde: ${e.toString()}')),
        );
      }
    }
  }
}
