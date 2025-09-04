import 'dart:developer';

import 'package:flutter/foundation.dart';
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
      final productJson = product.toJson();
      log('Creating product with data: $productJson');
      
      final response = await _apiService.post(
        _basePath,
        body: productJson,
      );
      
      log('Received response: $response');
      
      // If response is null, return the original product with a success status
      if (response == null) {
        log('No response body received, assuming success and returning original product');
        return product;
      }
      
      // If response is a Map, use it to create the product
      if (response is Map<String, dynamic>) {
        return ProductApiModel.fromJson(response);
      }
      
      // If we get here, the response is of an unexpected type
      log('Unexpected response type: ${response.runtimeType}');
      return product;
    } catch (e, stackTrace) {
      log('Error in createProduct', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update an existing product
  Future<ProductApiModel> updateProduct(ProductApiModel product) async {
    try {
      final productJson = product.toJson();
      log('Updating product ${product.id} with data: $productJson');
      
      final response = await _apiService.put(
        '$_basePath/${product.id}',
        body: productJson,
      );
      
      log('Received response: $response');
      
      // If response is null, return the original product with a success status
      if (response == null) {
        log('No response body received, assuming success and returning original product');
        return product;
      }
      
      // If response is a Map, use it to update the product
      if (response is Map<String, dynamic>) {
        return ProductApiModel.fromJson(response);
      }
      
      // If we get here, the response is of an unexpected type
      log('Unexpected response type: ${response.runtimeType}');
      return product;
    } catch (e, stackTrace) {
      log('Error in updateProduct', error: e, stackTrace: stackTrace);
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
