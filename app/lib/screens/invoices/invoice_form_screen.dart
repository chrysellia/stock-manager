import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/customer.dart';
import 'package:gestion_stock_epicerie/models/invoice.dart';
import 'package:gestion_stock_epicerie/routes.dart';
import 'package:gestion_stock_epicerie/screens/customers/customer_form_screen.dart';
import 'package:gestion_stock_epicerie/services/customer_service.dart';
import 'package:gestion_stock_epicerie/services/invoice_service.dart';
import 'package:intl/intl.dart';

class InvoiceFormScreen extends StatefulWidget {
  final Invoice? invoice;

  const InvoiceFormScreen({
    super.key,
    this.invoice,
  });

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceService = InvoiceService();
  final _customerService = CustomerService();
  final _invoiceNumberController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _amountController = TextEditingController();
  final _customerSearchController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCustomers = false;
  String? _errorMessage;
  Customer? _selectedCustomer;
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadInvoiceData();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      _customers = await _customerService.getActiveCustomers();
      if (widget.invoice != null && widget.invoice!.customerId != null) {
        _selectedCustomer = _customers.firstWhere(
          (c) => c.id == widget.invoice!.customerId,
          orElse: () => _customers.isNotEmpty ? _customers.first : Customer(name: ''),
        );
      } else if (_customers.isNotEmpty) {
        _selectedCustomer = _customers.first;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des clients: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCustomers = false);
      }
    }
  }

  void _loadInvoiceData() {
    if (widget.invoice != null) {
      _invoiceNumberController.text = widget.invoice!.invoiceNumber;
      if (widget.invoice!.issueDate != null) {
        _issueDateController.text =
            DateFormat('yyyy-MM-dd').format(widget.invoice!.issueDate!);
      }
      if (widget.invoice!.dueDate != null) {
        _dueDateController.text =
            DateFormat('yyyy-MM-dd').format(widget.invoice!.dueDate!);
      }
      _amountController.text = widget.invoice!.total.toStringAsFixed(2);
    } else {
      final now = DateTime.now();
      _issueDateController.text = DateFormat('yyyy-MM-dd').format(now);
      _dueDateController.text = DateFormat('yyyy-MM-dd')
          .format(now.add(const Duration(days: 30)));
    }
  }

  Future<void> _generateInvoiceNumber() async {
    final number = await _invoiceService.generateInvoiceNumber();
    setState(() {
      _invoiceNumberController.text = number;
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      setState(() => _errorMessage = 'Veuillez sélectionner un client');
      return;
    }

    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      // Parse dates - we use ! because we know these fields are validated
      final issueDate = DateTime.parse(_issueDateController.text);
      final dueDate = DateTime.parse(_dueDateController.text);

      final invoice = Invoice(
        id: widget.invoice?.id,
        invoiceNumber: _invoiceNumberController.text,
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        issueDate: issueDate,
        dueDate: dueDate,
        status: widget.invoice?.status ?? 'draft',
        items: const [], // Initialize with empty items or use existing items if editing
        createdAt: widget.invoice?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _invoiceService.save(invoice);
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sauvegarde: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addNewCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerFormScreen(),
      ),
    );
    
    if (result is Customer) {
      // If we get back a customer, use it
      setState(() {
        _selectedCustomer = result;
      });
    } else if (result == true) {
      // If we just get a success flag, refresh the list
      await _loadCustomers();
      
      // Try to find the most recently added customer
      if (_customers.isNotEmpty) {
        // Sort by creation date (newest first) and take the first one
        _customers.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        setState(() {
          _selectedCustomer = _customers.first;
        });
      }
    }
  }

  void _showCustomerSearch() {
    _customerSearchController.clear();
    List<Customer> filteredCustomers = List.from(_customers);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _customerSearchController,
                    decoration: const InputDecoration(
                      labelText: 'Rechercher un client',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        filteredCustomers = _customers
                            .where((customer) => customer.name
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: Column(
                      children: [
                        // Add New Customer button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Nouveau client'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () async {
                              Navigator.pop(context); // Close the bottom sheet
                              await _addNewCustomer();
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        // Customer list
                        Expanded(
                          child: filteredCustomers.isEmpty
                              ? const Center(
                                  child: Text('Aucun client trouvé'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredCustomers.length,
                                  itemBuilder: (context, index) {
                                    final customer = filteredCustomers[index];
                                    return ListTile(
                                      title: Text(customer.name),
                                      subtitle: customer.phone != null
                                          ? Text(customer.phone!)
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          _selectedCustomer = customer;
                                        });
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice == null ? 'Nouvelle facture' : 'Modifier la facture'),
      ),
      body: _isLoading || _isLoadingCustomers
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
                    TextFormField(
                      controller: TextEditingController(
                        text: _selectedCustomer?.name ?? '',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Client',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _showCustomerSearch,
                        ),
                      ),
                      readOnly: true,
                      onTap: _showCustomerSearch,
                      validator: (value) {
                        if (_selectedCustomer == null) {
                          return 'Veuillez sélectionner un client';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _invoiceNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de facture',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _issueDateController,
                            decoration: InputDecoration(
                              labelText: 'Date d\'émission',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context, _issueDateController),
                              ),
                            ),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _dueDateController,
                            decoration: InputDecoration(
                              labelText: 'Date d\'échéance',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context, _dueDateController),
                              ),
                            ),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Montant',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveInvoice,
                      child: Text(widget.invoice == null ? 'Créer' : 'Mettre à jour'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _issueDateController.dispose();
    _dueDateController.dispose();
    _amountController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }
}