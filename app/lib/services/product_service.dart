import 'package:flutter/foundation.dart';
import 'package:gestion_stock_epicerie/models/product.dart';
import 'package:gestion_stock_epicerie/models/api_models/product_api_model.dart';
import 'package:gestion_stock_epicerie/services/api/product_api_service.dart';

/// Service class for managing product-related operations
/// Handles communication between the app and the product API
class ProductService {
  final ProductApiService _apiService = ProductApiService();

  /// Retrieves all products from the API
  /// 
  /// Returns a list of [Product] objects
  /// 
  /// Throws an exception if the API call fails
  Future<List<Product>> getAll() async {
    try {
      final apiProducts = await _apiService.getProducts();
      return apiProducts.map((apiProduct) => Product(
        id: apiProduct.id,
        name: apiProduct.name,
        description: apiProduct.description ?? '',
        price: apiProduct.price,
        quantity: apiProduct.quantity,
        category: apiProduct.category ?? 'Uncategorized',
        // minQuantity: apiProduct.minQuantity?.toDouble() ?? 5,
        // Add other fields as needed
      )).toList();
    } catch (e) {
      debugPrint('Error getting all products: $e');
      rethrow;
    }
  }

  /// Retrieves a single product by its ID
  /// 
  /// [id] The ID of the product to retrieve
  /// Returns the [Product] if found, null otherwise
  Future<Product?> getById(String id) async {
    try {
      final apiProduct = await _apiService.getProduct(id);
      return Product(
        id: apiProduct.id,
        name: apiProduct.name,
        description: apiProduct.description ?? '',
        price: apiProduct.price,
        quantity: apiProduct.quantity,
        category: apiProduct.category ?? 'Uncategorized',
        // minQuantity: null,
        // minQuantity: apiProduct.minQuantity?.toDouble() ?? 5,
        // Add other fields as needed
      );
    } catch (e) {
      debugPrint('Error getting product by id $id: $e');
      return null;
    }
  }

  /// Saves a product to the API
  /// 
  /// If the product has an empty ID, it will be created as a new product.
  /// Otherwise, it will update the existing product.
  /// 
  /// [product] The product to save
  /// Returns the saved [Product] with updated ID if it was created
  /// 
  /// Throws an exception if the API call fails
  Future<Product> save(Product product) async {
    try {
      final now = DateTime.now();
      final apiProduct = ProductApiModel(
        id: product.id ?? '',
        name: product.name,
        description: product.description,
        price: product.price,
        quantity: product.quantity.toInt(),
        category: product.category,
        imageUrl: product.imageUrl,
        createdAt: product.createdAt ?? now,
        updatedAt: now,
      );

      final savedProduct = (product.id?.isEmpty ?? true)
          ? await _apiService.createProduct(apiProduct)
          : await _apiService.updateProduct(apiProduct);

      return product.copyWith(id: savedProduct.id);
    } catch (e) {
      debugPrint('Error saving product: $e');
      rethrow;
    }
  }

  /// Deletes a product by its ID
  /// 
  /// [id] The ID of the product to delete
  /// 
  /// Throws an exception if the API call fails
  Future<void> delete(String id) async {
    try {
      await _apiService.deleteProduct(id);
    } catch (e) {
      debugPrint('Error deleting product $id: $e');
      rethrow;
    }
  }

  /// Retrieves all products that are out of stock
  /// 
  /// Returns a list of [Product] objects with quantity <= 0
  Future<List<Product>> getOutOfStockProducts() async {
    final products = await getAll();
    return products.where((p) => p.quantity <= 0).toList();
  }

  /// Retrieves all products that are low in stock
  /// 
  /// Returns a list of [Product] objects where quantity > 0 
  /// and quantity <= minQuantity
  Future<List<Product>> getLowStockProducts() async {
    final products = await getAll();
    return products.where((p) => p.isLowStock && p.quantity > 0).toList();
  }

  /// Searches products by name or description
  /// 
  /// [query] The search term to match against product names and descriptions
  /// Returns a list of matching [Product] objects
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    final products = await getAll();
    final lowerQuery = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Updates the stock quantity of a product
  /// 
  /// [productId] The ID of the product to update
  /// [quantityChange] The amount to add (positive) or subtract (negative)
  /// 
  /// Throws an exception if the product is not found or if the update fails
  Future<void> updateStock(String productId, int quantityChange) async {
    final product = await getById(productId);
    if (product != null) {
      final newQuantity = product.quantity + quantityChange;
      if (newQuantity >= 0) {
        await save(product.copyWith(quantity: newQuantity));
      }
    }
  }

  /// Groups products by their category
  /// 
  /// Returns a map where keys are category names and values are lists of [Product]
  /// objects belonging to that category
  Future<Map<String, List<Product>>> getProductsByCategory() async {
    final products = await getAll();
    final productsByCategory = <String, List<Product>>{};

    for (var product in products) {
      final category = product.category;
      productsByCategory.putIfAbsent(category, () => []).add(product);
    }

    return productsByCategory;
  }

  /// Retrieves minimal product data for selection dialogs
  /// 
  /// Returns a list of maps containing only the essential product data
  /// needed for selection UIs
  Future<List<Map<String, dynamic>>> getProductsForSelection() async {
    try {
      final products = await _apiService.getProductsForSelection();
      return products.map((product) => {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'quantity': product.quantity,
      }).toList();
    } catch (e) {
      debugPrint('Error getting products for selection: $e');
      return [];
    }
  }
}
