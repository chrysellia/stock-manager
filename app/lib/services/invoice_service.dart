import 'package:gestion_stock_epicerie/models/invoice.dart';
import 'package:gestion_stock_epicerie/services/crud_service.dart';

class InvoiceService extends CrudService<Invoice> {
  InvoiceService()
      : super(
          collectionName: 'invoices',
          fromJson: (json) => Invoice.fromJson(json),
        );

  // Get all invoices with optional filtering
  Future<List<Invoice>> getInvoices({
    String? status,
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var invoices = await getAll();
    
    if (status != null) {
      invoices = invoices.where((i) => i.status == status).toList();
    }
    
    if (customerId != null) {
      invoices = invoices.where((i) => i.customerId == customerId).toList();
    }
    
    if (startDate != null) {
      invoices = invoices.where((i) => 
        i.issueDate != null && 
        i.issueDate!.isAfter(startDate.subtract(const Duration(days: 1)))
      ).toList();
    }
    
    if (endDate != null) {
      invoices = invoices.where((i) => 
        i.issueDate != null && 
        i.issueDate!.isBefore(endDate.add(const Duration(days: 1)))
      ).toList();
    }
    
    // Sort by issue date (newest first)
    invoices.sort((a, b) => 
      (b.issueDate ?? DateTime(0)).compareTo(a.issueDate ?? DateTime(0))
    );
    
    return invoices;
  }

  // Get draft invoices
  Future<List<Invoice>> getDraftInvoices() async {
    return await getInvoices(status: 'draft');
  }

  // Get paid invoices
  Future<List<Invoice>> getPaidInvoices() async {
    return await getInvoices(status: 'paid');
  }

  // Get overdue invoices
  Future<List<Invoice>> getOverdueInvoices() async {
    final now = DateTime.now();
    final invoices = await getInvoices(status: 'sent');
    return invoices.where((i) => 
      i.dueDate != null && 
      i.dueDate!.isBefore(now) &&
      i.status != 'paid' &&
      i.status != 'cancelled'
    ).toList();
  }

  // Get invoices for a specific customer
  Future<List<Invoice>> getCustomerInvoices(String customerId) async {
    return await getInvoices(customerId: customerId);
  }

  // Generate a new invoice number
  Future<String> generateInvoiceNumber() async {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    
    // Get the count of invoices this month
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final monthlyInvoices = await getInvoices(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    
    final nextNumber = monthlyInvoices.length + 1;
    return 'INV-$year$month-${nextNumber.toString().padLeft(4, '0')}';
  }

  // Mark an invoice as paid
  Future<void> markAsPaid(String invoiceId) async {
    final invoice = await getById(invoiceId);
    if (invoice != null) {
      await save(invoice.copyWith(
        status: 'paid',
        updatedAt: DateTime.now(),
      ));
    }
  }

  // Mark an invoice as sent
  Future<void> markAsSent(String invoiceId) async {
    final invoice = await getById(invoiceId);
    if (invoice != null && invoice.status == 'draft') {
      await save(invoice.copyWith(
        status: 'sent',
        issueDate: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  // Cancel an invoice
  Future<void> cancelInvoice(String invoiceId, String? reason) async {
    final invoice = await getById(invoiceId);
    if (invoice != null) {
      await save(invoice.copyWith(
        status: 'cancelled',
        notes: '${invoice.notes ?? ''}\n\nCancelled: $reason',
        updatedAt: DateTime.now(),
      ));
    }
  }

  // Get sales statistics
  Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final invoices = await getInvoices(
      startDate: startDate,
      endDate: endDate,
    );
    
    final paidInvoices = invoices.where((i) => i.status == 'paid');
    final totalSales = paidInvoices.fold(0.0, (sum, i) => sum + i.total);
    final totalInvoices = paidInvoices.length;
    final averageInvoiceValue = totalInvoices > 0 ? totalSales / totalInvoices : 0;
    
    return {
      'totalSales': totalSales,
      'totalInvoices': totalInvoices,
      'averageInvoiceValue': averageInvoiceValue,
      'paidInvoices': paidInvoices.length,
      'pendingInvoices': invoices.where((i) => ['draft', 'sent'].contains(i.status)).length,
      'overdueInvoices': (await getOverdueInvoices()).length,
    };
  }
}
