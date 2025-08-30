import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/stock.dart';
import 'package:gestion_stock_epicerie/services/stock_service.dart';
import 'package:gestion_stock_epicerie/widgets/stock_movement_dialog.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final StockService _stockService = StockService();
  final TextEditingController _searchController = TextEditingController();

  List<StockMovement> _movements = [];
  List<StockMovement> _filteredMovements = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMovements();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovements() async {
    setState(() => _isLoading = true);
    try {
      final movements = await _stockService.getRecentMovements(limit: 100);
      setState(() {
        _movements = movements;
        _filteredMovements = _filterMovements(movements, _searchQuery);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors du chargement des mouvements: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filteredMovements = _filterMovements(_movements, _searchQuery);
    });
  }

  List<StockMovement> _filterMovements(
      List<StockMovement> movements, String query) {
    if (query.isEmpty) return movements;

    final lowercaseQuery = query.toLowerCase();
    return movements.where((movement) {
      return movement.productName.toLowerCase().contains(lowercaseQuery) ||
          movement.typeLabel.toLowerCase().contains(lowercaseQuery) ||
          (movement.reference?.toLowerCase().contains(lowercaseQuery) ??
              false) ||
          (movement.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Future<void> _showAddMovementDialog() async {
    final result = await showDialog<StockMovement>(
      context: context,
      builder: (context) => const StockMovementDialog(),
    );

    if (result != null && mounted) {
      try {
        await _stockService.save(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mouvement enregistré avec succès')),
          );
          _loadMovements();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'enregistrement: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des stocks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMovements,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et boutons d'action
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un mouvement...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                // Boutons d'action rapide
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.add_circle_outline,
                        label: 'Nouveau',
                        color: Theme.of(context).primaryColor,
                        onPressed: _showAddMovementDialog,
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.arrow_downward,
                        label: 'Entrée',
                        color: Colors.green,
                        onPressed: () => _showAddMovementDialog(),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.arrow_upward,
                        label: 'Sortie',
                        color: Colors.red,
                        onPressed: () => _showAddMovementDialog(),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.adjust,
                        label: 'Ajustement',
                        color: Colors.orange,
                        onPressed: () => _showAddMovementDialog(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des mouvements
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMovements.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Aucun mouvement enregistré.\nCommencez par ajouter un mouvement.'
                              : 'Aucun mouvement trouvé pour votre recherche.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredMovements.length,
                        itemBuilder: (context, index) {
                          final movement = _filteredMovements[index];
                          return _buildMovementCard(movement);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMovementDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withOpacity(0.5)),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }

  Widget _buildMovementCard(StockMovement movement) {
    final isEntry = movement.isEntry || movement.isInitial;
    final icon = isEntry ? Icons.arrow_downward : Icons.arrow_upward;
    final color = isEntry ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          movement.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(movement.typeLabel),
            if (movement.notes != null) Text(movement.notes!),
            Text(
              '${movement.movementDate.day}/${movement.movementDate.month}/${movement.movementDate.year} ${movement.movementDate.hour}:${movement.movementDate.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isEntry ? '+' : '-'}${movement.quantity}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (movement.reference != null)
              Text(
                movement.reference!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        onTap: () {
          // TODO: Afficher les détails du mouvement
        },
      ),
    );
  }
}
