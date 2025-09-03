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
    this.isActive = true
  }) : super() {
    this.id = id ?? const Uuid().v4();
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
      isActive: json['isActive'] ?? true
    );
  }

  // Convertir le fournisseur en Map (pour la sérialisation)
  @override
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

    // Don't include ID for new supplier creation
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
    addIfNotNull('website', website);
    addIfNotNull('taxNumber', taxNumber);
    addIfNotNull('notes', notes);
    addIfNotNull('isActive', isActive);
    
    return data;
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
      isActive: isActive ?? this.isActive
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
