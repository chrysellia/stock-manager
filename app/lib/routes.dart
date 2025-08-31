import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/invoice.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/customers/customers_screen.dart';
import 'screens/suppliers/suppliers_screen.dart';
import 'screens/invoices/invoices_screen.dart';
import 'screens/invoices/invoice_form_screen.dart';
// Importer les autres écrans au fur et à mesure
// import 'screens/stock/stock_screen.dart';
// import 'screens/settings/settings_screen.dart';

class AppRoutes {
  // Routes statiques
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String stock = '/stock';
  static const String suppliers = '/suppliers';
  static const String invoices = '/invoices';
  static const String customers = '/customers';
  static const String settings = '/settings';

  // Générateur de routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      // Décommenter et ajouter les autres routes au fur et à mesure
      // case stock:
      //   return MaterialPageRoute(builder: (_) => const StockScreen());
      case suppliers:
        return MaterialPageRoute(builder: (_) => const SuppliersScreen());
      case invoices:
        return MaterialPageRoute(builder: (_) => const InvoicesScreen());
      case '$invoices/new':
        return MaterialPageRoute(builder: (_) => const InvoiceFormScreen());
      case '$invoices/edit':
        final invoice = settings.arguments as Invoice?;
        return MaterialPageRoute(
          builder: (_) => InvoiceFormScreen(invoice: invoice),
        );
      case customers:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());
      // case settings:
      //   return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return _errorRoute(settings.name ?? 'inconnue');
    }
  }

  // Route d'erreur
  static Route<dynamic> _errorRoute(String routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erreur de navigation')),
        body: Center(
          child: Text('Aucune route définie pour "$routeName"'),
        ),
      ),
    );
  }

  // Configuration de la navigation
  static final navigatorKey = GlobalKey<NavigatorState>();

  // Méthodes de navigation
  static Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateReplacement(String routeName,
      {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  static void goBack() {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }
  }
}
