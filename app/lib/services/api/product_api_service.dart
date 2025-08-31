import 'package:gestion_stock_epicerie/models/api_models/product_api_model.dart';
import 'package:gestion_stock_epicerie/services/api_service.dart';

class ProductApiService {
  final ApiService _apiService = ApiService();
  final String _basePath = 'products';

  // Get all products with minimal data for selection
  Future<List<ProductSelectionModel>> getProductsForSelection() async {
    try {
      final response = await _apiService.get('$_basePath/selection');
      return (response as List)
          .map((json) => ProductSelectionModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get all products with full details
  Future<List<ProductApiModel>> getProducts() async {
    try {
      final response = await _apiService.get(_basePath);
      return (response as List)
          .map((json) => ProductApiModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get a single product by ID
  Future<ProductApiModel> getProduct(String id) async {
    try {
      final response = await _apiService.get('$_basePath/$id');
      return ProductApiModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Create a new product
  Future<ProductApiModel> createProduct(ProductApiModel product) async {
    try {
      final response = await _apiService.post(
        _basePath,
        body: product.toJson(),
      );
      return ProductApiModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing product
  Future<ProductApiModel> updateProduct(ProductApiModel product) async {
    try {
      final response = await _apiService.put(
        '$_basePath/${product.id}',
        body: product.toJson(),
      );
      return ProductApiModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      await _apiService.delete('$_basePath/$id');
    } catch (e) {
      rethrow;
    }
  }
}
