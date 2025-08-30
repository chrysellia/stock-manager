import 'package:uuid/uuid.dart';
import 'base_model.dart';

class Supplier extends BaseModel {
  final String name;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? email;
  final String? website;
  final String? taxNumber;
  final String? notes;
  final bool isActive;

  Supplier({
    String? id,
    required this.name,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.phone,
    this.email,
    this.website,
    this.taxNumber,
    this.notes,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super() {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // Créer un fournisseur à partir d'un Map (pour la désérialisation)
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postalCode'],
      country: json['country'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      taxNumber: json['taxNumber'],
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Convertir le fournisseur en Map (pour la sérialisation)
  @override
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
      'website': website,
      'taxNumber': taxNumber,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Créer une copie du fournisseur avec des mises à jour
  Supplier copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? phone,
    String? email,
    String? website,
    String? taxNumber,
    String? notes,
    bool? isActive,
    required DateTime updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      taxNumber: taxNumber ?? this.taxNumber,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Vérifier si le fournisseur est valide
  bool get isValid => name.trim().isNotEmpty;

  // Obtenir l'adresse complète formatée
  String? get formattedAddress {
    final parts = [
      address,
      if (postalCode != null || city != null)
        [postalCode, city].where((e) => e != null).join(' '),
      country,
    ].where((e) => e != null && e.isNotEmpty).toList();

    return parts.isNotEmpty ? parts.join('\n') : null;
  }

  // Obtenir les coordonnées complètes formatées
  String? get contactInfo {
    final parts = [
      if (phone != null) 'Tél: $phone',
      if (email != null) 'Email: $email',
      if (website != null) 'Site: $website',
      if (taxNumber != null) 'N° TVA: $taxNumber',
    ];

    return parts.isNotEmpty ? parts.join('\n') : null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supplier &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Supplier{id: $id, name: $name, isActive: $isActive}';
  }
}
