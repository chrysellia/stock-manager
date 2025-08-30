import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/base_model.dart';

abstract class CrudService<T extends BaseModel> {
  final String collectionName;
  final T Function(Map<String, dynamic>) fromJson;

  CrudService({
    required this.collectionName,
    required this.fromJson,
  });

  // Méthode pour obtenir la clé de stockage
  String _getStorageKey() => '${collectionName}_collection';

  // Récupérer tous les éléments
  Future<List<T>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_getStorageKey());

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      // Décoder la chaîne JSON en une liste dynamique
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Convertir chaque élément JSON en objet T
      return jsonList.map((item) {
        if (item is Map<String, dynamic>) {
          return fromJson(item);
        } else if (item is Map) {
          // Si pour une raison quelconque c'est un Map<dynamic, dynamic>
          return fromJson(Map<String, dynamic>.from(item));
        } else {
          throw FormatException('Format de données invalide: $item');
        }
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
      // En cas d'erreur, on retourne une liste vide
      return [];
    }
  }

  // Récupérer un élément par son ID
  Future<T?> getById(String id) async {
    if (id.isEmpty) return null;

    final items = await getAll();
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Créer ou mettre à jour un élément
  Future<T> save(T item) async {
    try {
      final items = await getAll();
      final index = items.indexWhere((i) => i.id == item.id);
      final now = DateTime.now();

      if (index >= 0) {
        // Mise à jour
        items[index] = item..updatedAt = now;
      } else {
        // Création
        item.id = DateTime.now().millisecondsSinceEpoch.toString();
        item.createdAt = now;
        item.updatedAt = now;
        items.add(item);
      }

      await _saveAll(items);
      return item;
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
      rethrow;
    }
  }

  // Supprimer un élément
  Future<bool> delete(String id) async {
    if (id.isEmpty) return false;

    try {
      final items = await getAll();
      items.removeWhere((item) => item.id == id);
      return await _saveAll(items);
    } catch (e) {
      print('Erreur lors de la suppression: $e');
      return false;
    }
  }

  // Sauvegarder tous les éléments
  Future<bool> _saveAll(List<T> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(_getStorageKey(), jsonString);
    } catch (e) {
      print('Erreur lors de la sérialisation: $e');
      return false;
    }
  }
}
