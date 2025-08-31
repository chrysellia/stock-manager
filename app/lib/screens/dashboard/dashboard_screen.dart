import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/routes.dart';
import 'package:gestion_stock_epicerie/screens/products/products_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          _pageController.jumpToPage(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tableau de bord'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Naviguer vers les notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                // TODO: Naviguer vers les paramètres
              },
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: [
            // Écran du tableau de bord
            _buildDashboardContent(),
            // Écran des produits
            const ProductsScreen(),
            // Écran des ventes (à implémenter)
            const Center(child: Text('Écran des ventes')),
            // Écran des paramètres (à implémenter)
            const Center(child: Text('Paramètres')),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec bonjour et date
          _buildHeader(),
          const SizedBox(height: 24),

          // Cartes de statistiques
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // Section rapide
          Text(
            'Accès rapide',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(context),
          const SizedBox(height: 24),

          // Dernières activités
          Text(
            'Dernières activités',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[600],
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Produits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale_outlined),
          activeIcon: Icon(Icons.point_of_sale),
          label: 'Ventes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Paramètres',
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final formattedDate =
        '${_getWeekday(now.weekday)} ${now.day} ${_getMonth(now.month)} ${now.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour,',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bienvenue sur votre tableau de bord',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          formattedDate,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Produits',
          value: '156',
          icon: Icons.inventory_2_outlined,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Stock bas',
          value: '24',
          icon: Icons.warning_amber_outlined,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Ventes du jour',
          value: '1,250 €',
          icon: Icons.euro_symbol_outlined,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Nouvelles commandes',
          value: '8',
          icon: Icons.shopping_cart_outlined,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final quickActions = [
      {
        'title': 'Produits',
        'icon': Icons.inventory_2_outlined,
        'color': Colors.blue,
        'onTap': () => Navigator.pushNamed(context, AppRoutes.products),
      },
      {
        'title': 'Clients',
        'icon': Icons.people_outline,
        'color': Colors.purple,
        'onTap': () => Navigator.pushNamed(context, AppRoutes.customers),
      },
      {
        'title': 'Stock',
        'icon': Icons.warehouse_outlined,
        'color': Colors.orange,
        'onTap': () {
          // TODO: Implémenter la navigation vers l'écran de gestion des stocks
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fonctionnalité à venir')),
          );
        },
      },
      {
        'title': 'Fournisseurs',
        'icon': Icons.local_shipping_outlined,
        'color': Colors.green,
        'onTap': () => Navigator.pushNamed(context, AppRoutes.suppliers),
      },
      {
        'title': 'Factures',
        'icon': Icons.receipt_long_outlined,
        'color': Colors.purple,
        'onTap': () => Navigator.pushNamed(context, AppRoutes.invoices),
      },
      {
        'title': 'Rapports',
        'icon': Icons.bar_chart_outlined,
        'color': Colors.amber,
        'onTap': () {
          // TODO: Implémenter la navigation vers l'écran des rapports
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fonctionnalité à venir')),
          );
        },
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1,
      children: quickActions
          .map((action) => _buildQuickActionCard(
                title: action['title'] as String,
                icon: action['icon'] as IconData,
                color: action['color'] as Color,
                onTap: action['onTap'] as VoidCallback,
              ))
          .toList(),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    final activities = [
      {
        'title': 'Nouvelle vente enregistrée',
        'subtitle': 'Commande #4587 - 125,50 €',
        'time': 'Il y a 5 min',
        'icon': Icons.payment_outlined,
        'color': Colors.green,
      },
      {
        'title': 'Stock mis à jour',
        'subtitle': 'Produit "Sucre en poche 1kg" réapprovisionné',
        'time': 'Il y a 2h',
        'icon': Icons.inventory_outlined,
        'color': Colors.blue,
      },
      {
        'title': 'Nouveau fournisseur ajouté',
        'subtitle': 'Fournisseur "Distri Alimentaire"',
        'time': 'Hier',
        'icon': Icons.person_add_outlined,
        'color': Colors.purple,
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: activities.map((activity) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity['color'] as Color? ?? Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity['icon'] as IconData? ?? Icons.notifications_none,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(activity['title'] as String),
            subtitle: Text(activity['subtitle'] as String),
            trailing: Text(
              activity['time'] as String,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          );
        }).toList(),
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    const months = [
      '',
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return months[month];
  }
}
