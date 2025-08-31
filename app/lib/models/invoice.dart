import 'package:uuid/uuid.dart';
import 'base_model.dart';
import 'product.dart';
import 'customer.dart';

class InvoiceItem {
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double discountPercentage;
  final String? notes;

  const InvoiceItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discountPercentage = 0.0,
    this.notes,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      productId: json['productId'],
      productName: json['productName'],
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discountPercentage': discountPercentage,
      if (notes != null) 'notes': notes,
    };
  }

  double get subtotal => quantity * unitPrice;
  
  double get discountAmount => subtotal * (discountPercentage / 100);
  
  double get total => subtotal - discountAmount;
}

class Invoice extends BaseModel {
  final String invoiceNumber;
  final String? customerId;
  final String? customerName;
  final DateTime? dueDate;
  final DateTime? issueDate;
  final List<InvoiceItem> items;
  final double taxRate;
  final double discountPercentage;
  final String? notes;
  final String status; // draft, sent, paid, cancelled
  final String? reference;
  final String? paymentTerms;
  final String? shippingAddress;
  final double shippingCost;
  final String? shippingMethod;

  Invoice({
    String? id,
    required this.invoiceNumber,
    this.customerId,
    this.customerName,
    this.dueDate,
    this.issueDate,
    List<InvoiceItem>? items,
    this.taxRate = 0.0,
    this.discountPercentage = 0.0,
    this.notes,
    this.status = 'draft',
    this.reference,
    this.paymentTerms,
    this.shippingAddress,
    this.shippingCost = 0.0,
    this.shippingMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : items = items ?? [],
        super() {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      issueDate: json['issueDate'] != null ? DateTime.parse(json['issueDate']) : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
      status: json['status'] ?? 'draft',
      reference: json['reference'],
      paymentTerms: json['paymentTerms'],
      shippingAddress: json['shippingAddress'],
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      shippingMethod: json['shippingMethod'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'dueDate': dueDate?.toIso8601String(),
      'issueDate': issueDate?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'taxRate': taxRate,
      'discountPercentage': discountPercentage,
      'notes': notes,
      'status': status,
      'reference': reference,
      'paymentTerms': paymentTerms,
      'shippingAddress': shippingAddress,
      'shippingCost': shippingCost,
      'shippingMethod': shippingMethod,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Calculated properties
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  
  double get taxAmount => subtotal * (taxRate / 100);
  
  double get invoiceDiscount => subtotal * (discountPercentage / 100);
  
  double get totalBeforeShipping => subtotal + taxAmount - invoiceDiscount;
  
  double get total => totalBeforeShipping + shippingCost;
  
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity.toInt());

  // Create a copy of the invoice with updated values
  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    DateTime? dueDate,
    DateTime? issueDate,
    List<InvoiceItem>? items,
    double? taxRate,
    double? discountPercentage,
    String? notes,
    String? status,
    String? reference,
    String? paymentTerms,
    String? shippingAddress,
    double? shippingCost,
    String? shippingMethod,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      dueDate: dueDate ?? this.dueDate,
      issueDate: issueDate ?? this.issueDate,
      items: items ?? List.from(this.items),
      taxRate: taxRate ?? this.taxRate,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      reference: reference ?? this.reference,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingCost: shippingCost ?? this.shippingCost,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
