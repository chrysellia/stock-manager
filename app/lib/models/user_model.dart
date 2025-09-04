class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      role: json['role'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'token': token,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
