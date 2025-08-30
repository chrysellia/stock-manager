import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/supplier.dart';
import 'package:gestion_stock_epicerie/services/supplier_service.dart';
import 'package:gestion_stock_epicerie/theme/app_theme.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormScreen({
    super.key,
    this.supplier,
  });

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierService = SupplierService();

  // Contrôleurs pour les champs du formulaire
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _taxNumberController;
  late TextEditingController _notesController;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs avec les valeurs existantes ou des valeurs vides
    final supplier = widget.supplier;
    _nameController = TextEditingController(text: supplier?.name ?? '');
    _addressController = TextEditingController(text: supplier?.address ?? '');
    _cityController = TextEditingController(text: supplier?.city ?? '');
    _postalCodeController =
        TextEditingController(text: supplier?.postalCode ?? '');
    _countryController = TextEditingController(text: supplier?.country ?? '');
    _phoneController = TextEditingController(text: supplier?.phone ?? '');
    _emailController = TextEditingController(text: supplier?.email ?? '');
    _websiteController = TextEditingController(text: supplier?.website ?? '');
    _taxNumberController =
        TextEditingController(text: supplier?.taxNumber ?? '');
    _notesController = TextEditingController(text: supplier?.notes ?? '');
    _isActive = supplier?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _taxNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supplier = Supplier(
        id: widget.supplier?.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        postalCode: _postalCodeController.text.trim().isNotEmpty
            ? _postalCodeController.text.trim()
            : null,
        country: _countryController.text.trim().isNotEmpty
            ? _countryController.text.trim()
            : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        taxNumber: _taxNumberController.text.trim().isNotEmpty
            ? _taxNumberController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        isActive: _isActive,
      );

      Supplier result;
      if (widget.supplier != null) {
        result = await _supplierService.update(supplier);
      } else {
        result = await _supplierService.save(supplier);
      }

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sauvegarde du fournisseur: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier le fournisseur' : 'Nouveau fournisseur'),
        actions: [
          if (isEdit) ...[
            Switch(
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
              activeThumbColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveSupplier,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section Informations de base
                    _buildSectionHeader('Informations de base'),
                    const SizedBox(height: 8),

                    // Nom du fournisseur
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du fournisseur *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Section Coordonnées
                    _buildSectionHeader('Coordonnées'),
                    const SizedBox(height: 8),

                    // Adresse
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Ville et Code postal
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _postalCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Code postal',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'Ville',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Pays
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Pays',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Contact
                    _buildSectionHeader('Contact'),
                    const SizedBox(height: 8),

                    // Téléphone et Email
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Site web
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Site web',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                        hintText: 'https://',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 24),

                    // Section Informations complémentaires
                    _buildSectionHeader('Informations complémentaires'),
                    const SizedBox(height: 8),

                    // Numéro de TVA/SIRET
                    TextFormField(
                      controller: _taxNumberController,
                      decoration: const InputDecoration(
                        labelText: 'N° TVA/SIRET',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Bouton d'enregistrement
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveSupplier,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isEdit ? 'Mettre à jour' : 'Enregistrer'),
                    ),

                    // Message d'erreur
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
