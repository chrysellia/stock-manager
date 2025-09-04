import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/invoice.dart';
import 'package:gestion_stock_epicerie/models/product.dart';
import 'package:gestion_stock_epicerie/widgets/product_selection_dialog.dart';

class InvoiceItemsList extends StatefulWidget {
  final List<InvoiceItem> items;
  final Function(List<InvoiceItem>) onItemsChanged;

  const InvoiceItemsList({
    Key? key,
    required this.items,
    required this.onItemsChanged,
  }) : super(key: key);

  @override
  _InvoiceItemsListState createState() => _InvoiceItemsListState();
}

class _InvoiceItemsListState extends State<InvoiceItemsList> {
  late List<InvoiceItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void didUpdateWidget(covariant InvoiceItemsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = List.from(widget.items);
    }
  }

  Future<void> _addProducts() async {
    final selectedProducts = await showDialog<List<Product>>(
      context: context,
      builder: (context) => ProductSelectionDialog(
        selectedProducts: _items
            .map((i) => Product(
                  id: i.productId,
                  name: i.productName,
                  price: i.unitPrice,
                ))
            .toList(),
      ),
    );

    if (selectedProducts != null) {
      setState(() {
        // Add new products that aren't already in the list
        for (final product in selectedProducts) {
          if (!_items.any((item) => item.productId == product.id)) {
            _items.add(InvoiceItem(
              productId: product.id!,
              productName: product.name,
              quantity: 1,
              unitPrice: product.price,
            ));
          }
        }
        widget.onItemsChanged(_items);
      });
    }
  }

  void _updateItem(int index, InvoiceItem updatedItem) {
    setState(() {
      _items[index] = updatedItem;
      widget.onItemsChanged(_items);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      widget.onItemsChanged(_items);
    });
  }

  double get _totalAmount {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Articles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _addProducts,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter des produits'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('Aucun article ajouté'),
          )
        else
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _InvoiceItemRow(
              item: item,
              onChanged: (updated) => _updateItem(index, updated),
              onRemove: () => _removeItem(index),
            );
          }).toList(),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_totalAmount.toStringAsFixed(0)} MGA',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvoiceItemRow extends StatelessWidget {
  final InvoiceItem item;
  final Function(InvoiceItem) onChanged;
  final VoidCallback onRemove;

  const _InvoiceItemRow({
    Key? key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 100, // Fixed width for quantity field
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Qté',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final quantity = double.tryParse(value) ?? 0;
                      onChanged(item.copyWith(quantity: quantity));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.unitPrice.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Prix unitaire',
                      border: OutlineInputBorder(),
                      prefixText: 'MGA ',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0;
                      onChanged(item.copyWith(unitPrice: price));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sous-total: ${(item.quantity * item.unitPrice).toStringAsFixed(0)} MGA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
