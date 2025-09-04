import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/invoice.dart';
import 'package:gestion_stock_epicerie/screens/invoices/invoice_form_screen.dart';
import 'package:gestion_stock_epicerie/services/invoice_service.dart';
import 'package:gestion_stock_epicerie/theme/app_theme.dart';
import 'package:gestion_stock_epicerie/widgets/confirmation_dialog.dart';
import 'package:intl/intl.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  String _errorMessage = '';
  String _filterStatus = 'all';
  String _sortBy = 'date_desc';
  
  List<Invoice> _invoices = [];
  List<Invoice> _filteredInvoices = [];
  
  @override
  void initState() {
    super.initState();
    _loadInvoices();
    _searchController.addListener(_filterInvoices);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final invoices = await _invoiceService.getAll();
      setState(() {
        _invoices = invoices;
        _filterInvoices();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des factures: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _filterInvoices() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredInvoices = _invoices.where((invoice) {
        // Apply status filter
        if (_filterStatus != 'all' && invoice.status != _filterStatus) {
          return false;
        }
        
        // Apply search query
        if (query.isNotEmpty) {
          final matchesNumber = invoice.invoiceNumber.toLowerCase().contains(query);
          final matchesCustomer = invoice.customerName?.toLowerCase().contains(query) ?? false;
          final matchesReference = invoice.reference?.toLowerCase().contains(query) ?? false;
          
          if (!matchesNumber && !matchesCustomer && !matchesReference) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      // Apply sorting
      _sortInvoices();
    });
  }
  
  void _sortInvoices() {
    _filteredInvoices.sort((a, b) {
      switch (_sortBy) {
        case 'date_asc':
          return (a.issueDate ?? DateTime(0)).compareTo(b.issueDate ?? DateTime(0));
        case 'amount_desc':
          return b.total.compareTo(a.total);
        case 'amount_asc':
          return a.total.compareTo(b.total);
        case 'date_desc':
        default:
          return (b.issueDate ?? DateTime(0)).compareTo(a.issueDate ?? DateTime(0));
      }
    });
  }
  
  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Supprimer la facture',
        content: 'Êtes-vous sûr de vouloir supprimer la facture ${invoice.invoiceNumber} ?',
        confirmText: 'Supprimer'
      ),
    );
    
    if (confirmed == true) {
      try {
        await _invoiceService.delete(invoice.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facture supprimée avec succès')),
          );
          _loadInvoices();
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
  
  Future<void> _markAsPaid(Invoice invoice) async {
    try {
      await _invoiceService.markAsPaid(invoice.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facture marquée comme payée')),
        );
        _loadInvoices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factures'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToInvoiceForm(),
            tooltip: 'Nouvelle facture',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortInvoices();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date_desc',
                child: Text('Trier par date (récent)'),
              ),
              const PopupMenuItem(
                value: 'date_asc',
                child: Text('Trier par date (ancien)'),
              ),
              const PopupMenuItem(
                value: 'amount_desc',
                child: Text('Trier par montant (élevé)'),
              ),
              const PopupMenuItem(
                value: 'amount_asc',
                child: Text('Trier par montant (faible)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildSearchBar(),
          _buildStats(),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _errorMessage.isNotEmpty
                  ? Expanded(
                      child: Center(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _filteredInvoices.isEmpty
                      ? Expanded(
                          child: _buildEmptyState(),
                        )
                      : Expanded(
                          child: _buildInvoicesList(),
                        ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToInvoiceForm,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Toutes', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Brouillons', 'draft'),
            const SizedBox(width: 8),
            _buildFilterChip('Envoyées', 'sent'),
            const SizedBox(width: 8),
            _buildFilterChip('Payées', 'paid'),
            const SizedBox(width: 8),
            _buildFilterChip('En retard', 'overdue'),
            const SizedBox(width: 8),
            _buildFilterChip('Annulées', 'cancelled'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? value : 'all';
          _filterInvoices();
        });
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected 
            ? Theme.of(context).primaryColor 
            : Theme.of(context).dividerColor,
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher par numéro, client ou référence...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
  
  Widget _buildStats() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 0);
    
    final paidThisMonth = _invoices
        .where((i) => i.status == 'paid' && 
            i.issueDate != null && 
            i.issueDate!.isAfter(thisMonth) && 
            i.issueDate!.isBefore(nextMonth.add(const Duration(days: 1))))
        .fold(0.0, (sum, i) => sum + i.total);
    
    final pendingInvoices = _invoices
        .where((i) => i.status == 'sent' && 
            i.dueDate != null && 
            i.dueDate!.isBefore(now))
        .length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatCard(
            'CA (${DateFormat('MMM', 'fr_FR').format(now)})',
            '${paidThisMonth.toStringAsFixed(0)} MGA',
            Icons.euro,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Factures en retard',
            pendingInvoices.toString(),
            Icons.warning_amber_rounded,
            color: pendingInvoices > 0 ? Colors.orange : null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color ?? Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune facture trouvée',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _filterStatus == 'all'
                ? 'Commencez par créer votre première facture'
                : 'Aucune facture ne correspond à ce filtre',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToInvoiceForm,
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle facture'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInvoicesList() {
    return RefreshIndicator(
      onRefresh: _loadInvoices,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: _filteredInvoices.length,
        itemBuilder: (context, index) {
          final invoice = _filteredInvoices[index];
          return _buildInvoiceCard(invoice);
        },
      ),
    );
  }
  
  Widget _buildInvoiceCard(Invoice invoice) {
    final isOverdue = invoice.dueDate != null && 
        invoice.dueDate!.isBefore(DateTime.now()) && 
        invoice.status == 'sent';
    
    final statusColor = {
      'draft': Colors.blueGrey,
      'sent': isOverdue ? Colors.orange : Colors.blue,
      'paid': Colors.green,
      'cancelled': Colors.red,
    }[invoice.status] ?? Colors.grey;
    
    final statusText = {
      'draft': 'Brouillon',
      'sent': isOverdue ? 'En retard' : 'Envoyée',
      'paid': 'Payée',
      'cancelled': 'Annulée',
    }[invoice.status] ?? invoice.status;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToInvoiceForm(invoice: invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (invoice.customerName != null) ...[
                Text(
                  invoice.customerName!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
              ],
              if (invoice.issueDate != null) ...[
                Text(
                  'Émise le: ${DateFormat('dd/MM/yyyy').format(invoice.issueDate!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (invoice.dueDate != null) ...[
                Text(
                  'Échéance: ${DateFormat('dd/MM/yyyy').format(invoice.dueDate!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOverdue ? Colors.red : null,
                    fontWeight: isOverdue ? FontWeight.bold : null,
                  ),
                ),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${invoice.items.length} article${invoice.items.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${invoice.total.toStringAsFixed(0)} MGA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (invoice.status == 'sent' && isOverdue) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _markAsPaid(invoice),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Marquer comme payée'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToInvoiceForm({Invoice? invoice}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceFormScreen(invoice: invoice),
      ),
    );
    
    if (result == true) {
      _loadInvoices();
    }
  }
}

class InvoiceStatusFilter {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  
  const InvoiceStatusFilter({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
