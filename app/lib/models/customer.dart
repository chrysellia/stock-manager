import 'package:uuid/uuid.dart';
import 'base_model.dart';

class Customer extends BaseModel {
  final String name;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? email;
  final String? taxNumber;
  final String? notes;
  final bool isActive;
  final double? creditLimit;
  final double? currentCredit;

  Customer({
    String? id,
    required this.name,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.phone,
    this.email,
    this.taxNumber,
    this.notes,
    this.isActive = true,
    this.creditLimit,
    this.currentCredit = 0.0,
  }) : super() {
    this.id = id ?? const Uuid().v4();
  }

  // Create a copy of the customer with updated fields
  Customer copyWith(
      {String? id,
      String? name,
      String? address,
      String? city,
      String? postalCode,
      String? country,
      String? phone,
      String? email,
      String? taxNumber,
      String? notes,
      bool? isActive,
      double? creditLimit,
      double? currentCredit}) {
    return Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode,
        country: country ?? this.country,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        taxNumber: taxNumber ?? this.taxNumber,
        notes: notes ?? this.notes,
        isActive: isActive ?? this.isActive,
        creditLimit: creditLimit ?? this.creditLimit,
        currentCredit: currentCredit ?? this.currentCredit);
  }

  // Convert customer to JSON
  Map<String, dynamic> toJson({bool forCreation = false}) {
    final Map<String, dynamic> data = {};
    
    void addIfNotNull(String key, dynamic value) {
      if (value != null) {
        if (value is String && value.isNotEmpty) {
          data[key] = value;
        } else if (value is num || value is bool) {
          data[key] = value;
        } else if (value is String && value.isEmpty) {
          // Skip empty strings
        } else if (value != null) {
          data[key] = value;
        }
      }
    }

    // Don't include ID for new customer creation
    if (!forCreation) {
      addIfNotNull('id', id);
    }
    
    addIfNotNull('name', name);
    addIfNotNull('address', address);
    addIfNotNull('city', city);
    addIfNotNull('postalCode', postalCode);
    addIfNotNull('country', country);
    addIfNotNull('phone', phone);
    addIfNotNull('email', email);
    addIfNotNull('taxNumber', taxNumber);
    addIfNotNull('notes', notes);
    addIfNotNull('isActive', isActive);
    addIfNotNull('creditLimit', creditLimit ?? 0.0);
    addIfNotNull('currentCredit', currentCredit ?? 0.0);
    
    return data;
  }

  // Create a customer from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString(),
      name: json['name'].toString(), // Required field with default
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      postalCode: json['postalCode']?.toString(),
      country: json['country']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      taxNumber: json['taxNumber']?.toString(),
      notes: json['notes']?.toString(),
      isActive: json['isActive'] == null ? true : json['isActive'] as bool,
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      currentCredit: (json['currentCredit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
