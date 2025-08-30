import 'package:gestion_stock_epicerie/models/product.dart';
import 'package:gestion_stock_epicerie/services/crud_service.dart';

class ProductService extends CrudService<Product> {
  ProductService()
      : super(
          collectionName: 'products',
          fromJson: (json) => Product.fromJson(json),
        );

  // Récupérer les produits en rupture de stock
  Future<List<Product>> getOutOfStockProducts() async {
    final products = await getAll();
    return products.where((p) => p.quantity <= 0).toList();
  }

  // Récupérer les produits dont le stock est bas
  Future<List<Product>> getLowStockProducts() async {
    final products = await getAll();
    return products.where((p) => p.isLowStock && p.quantity > 0).toList();
  }

  // Rechercher des produits par nom ou code-barres
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return [];

    final products = await getAll();
    final lowerQuery = query.toLowerCase();

    return products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          (product.barcode?.toLowerCase().contains(lowerQuery) ?? false) ||
          (product.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Mettre à jour la quantité en stock
  Future<void> updateStock(String productId, int quantityChange) async {
    final product = await getById(productId);
    if (product != null) {
      final newQuantity = product.quantity + quantityChange;
      if (newQuantity >= 0) {
        await save(product.copyWith(quantity: newQuantity));
      }
    }
  }

  // Récupérer les produits par catégorie
  Future<Map<String, List<Product>>> getProductsByCategory() async {
    final products = await getAll();
    final Map<String, List<Product>> productsByCategory = {};

    for (var product in products) {
      final category = product.category;
      if (!productsByCategory.containsKey(category)) {
        productsByCategory[category] = [];
      }
      productsByCategory[category]!.add(product);
    }

    return productsByCategory;
  }
}
