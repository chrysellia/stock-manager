import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/customer.dart';
import 'package:gestion_stock_epicerie/services/customer_service.dart';
import 'package:gestion_stock_epicerie/theme/app_theme.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({
    super.key,
    this.customer,
  });

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerService = CustomerService();

  // Form field controllers
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _taxNumberController;
  late TextEditingController _notesController;
  late TextEditingController _creditLimitController;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final customer = widget.customer;
    _nameController = TextEditingController(text: customer?.name ?? '');
    _addressController = TextEditingController(text: customer?.address ?? '');
    _cityController = TextEditingController(text: customer?.city ?? '');
    _postalCodeController = TextEditingController(text: customer?.postalCode ?? '');
    _countryController = TextEditingController(text: customer?.country ?? '');
    _phoneController = TextEditingController(text: customer?.phone ?? '');
    _emailController = TextEditingController(text: customer?.email ?? '');
    _taxNumberController = TextEditingController(text: customer?.taxNumber ?? '');
    _notesController = TextEditingController(text: customer?.notes ?? '');
    _creditLimitController = TextEditingController(
      text: customer?.creditLimit?.toStringAsFixed(2) ?? '',
    );
    _isActive = customer?.isActive ?? true;
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
    _taxNumberController.dispose();
    _notesController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customer = Customer(
        id: widget.customer?.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        postalCode: _postalCodeController.text.trim().isNotEmpty ? _postalCodeController.text.trim() : null,
        country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        taxNumber: _taxNumberController.text.trim().isNotEmpty ? _taxNumberController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        isActive: _isActive,
        creditLimit: double.tryParse(_creditLimitController.text.trim()),
        currentCredit: widget.customer?.currentCredit ?? 0.0,
      );

      final savedCustomer = await _customerService.save(customer);

      if (mounted) {
        Navigator.of(context).pop(savedCustomer);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sauvegarde du client: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteCustomer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le client'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce client ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);

      try {
        await _customerService.delete(widget.customer!.id!);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Erreur lors de la suppression du client: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_formKey.currentState?.mounted ?? false) {
          // If form is dirty, show confirmation dialog
          if (_formKey.currentState?.mounted ?? false) {
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Modifications non enregistrées'),
                content: const Text('Voulez-vous enregistrer les modifications ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Ne pas enregistrer'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveCustomer().then((_) {
                        Navigator.of(context).pop(true);
                      });
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            );
            return shouldPop ?? false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.customer == null ? 'Nouveau client' : 'Modifier le client'),
          actions: [
            if (widget.customer != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _isLoading ? null : _deleteCustomer,
                tooltip: 'Supprimer',
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
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildContactSection(),
                      const SizedBox(height: 16),
                      _buildFinancialSection(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nom complet *',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Veuillez entrer un nom';
        }
        return null;
      },
    );
  }

  Widget _buildContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coordonnées',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Pays',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
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
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _taxNumberController,
              decoration: const InputDecoration(
                labelText: 'N° TVA',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations financières',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _creditLimitController,
              decoration: const InputDecoration(
                labelText: 'Limite de crédit (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.euro),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Veuillez entrer un montant valide';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Client actif'),
              value: _isActive,
              onChanged: (bool value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveCustomer,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Enregistrer',
              style: TextStyle(fontSize: 16),
            ),
    );
  }
}
