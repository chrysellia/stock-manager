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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super() {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // Create a customer from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postalCode'],
      country: json['country'],
      phone: json['phone'],
      email: json['email'],
      taxNumber: json['taxNumber'],
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      currentCredit: (json['currentCredit'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Convert customer to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'email': email,
      'taxNumber': taxNumber,
      'notes': notes,
      'isActive': isActive,
      'creditLimit': creditLimit,
      'currentCredit': currentCredit,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a copy of the customer with updated fields
  Customer copyWith({
    String? id,
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
    double? currentCredit,
  }) {
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
      currentCredit: currentCredit ?? this.currentCredit,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
