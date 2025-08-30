import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/stock.dart';
import 'package:gestion_stock_epicerie/services/stock_service.dart';

class StockMovementDialog extends StatefulWidget {
  final StockMovement? movement;
  final String? productId;
  final String? productName;

  const StockMovementDialog({
    super.key,
    this.movement,
    this.productId,
    this.productName,
  });

  @override
  State<StockMovementDialog> createState() => _StockMovementDialogState();
}

class _StockMovementDialogState extends State<StockMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _stockService = StockService();

  late StockMovementType _movementType;
  late TextEditingController _productIdController;
  late TextEditingController _productNameController;
  late TextEditingController _quantityController;
  late TextEditingController _referenceController;
  late TextEditingController _notesController;
  late TextEditingController _locationController;
  late DateTime _movementDate;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialiser avec les valeurs existantes ou des valeurs par défaut
    final movement = widget.movement;
    _movementType = movement?.type ?? StockMovementType.entry;
    _movementDate = movement?.movementDate ?? DateTime.now();

    _productIdController = TextEditingController(
      text: widget.productId ?? movement?.productId ?? '',
    );

    _productNameController = TextEditingController(
      text: widget.productName ?? movement?.productName ?? '',
    );

    _quantityController = TextEditingController(
      text: movement?.quantity.toString() ?? '1',
    );

    _referenceController = TextEditingController(
      text: movement?.reference ?? '',
    );

    _notesController = TextEditingController(
      text: movement?.notes ?? '',
    );

    _locationController = TextEditingController(
      text: movement?.location ?? 'Entrepôt principal',
    );
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveMovement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final movement = StockMovement(
        id: widget.movement?.id,
        productId: _productIdController.text.trim(),
        productName: _productNameController.text.trim(),
        quantity: int.parse(_quantityController.text),
        type: _movementType,
        movementDate: _movementDate,
        reference: _referenceController.text.trim().isNotEmpty
            ? _referenceController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        location: _locationController.text.trim(),
        userId: widget.movement?.userId, // Conserver l'utilisateur d'origine
      );

      if (widget.movement != null) {
        await _stockService.update(movement);
      } else {
        await _stockService.save(movement);
      }

      if (mounted) {
        Navigator.of(context).pop(movement);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sauvegarde: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.movement != null;
    final isProductLocked = widget.productId != null || isEdit;

    return AlertDialog(
      title:
          Text(isEdit ? 'Modifier le mouvement' : 'Nouveau mouvement de stock'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type de mouvement
              DropdownButtonFormField<StockMovementType>(
                value: _movementType,
                decoration: const InputDecoration(
                  labelText: 'Type de mouvement',
                  border: OutlineInputBorder(),
                ),
                items: StockMovementType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _movementType = value);
                  }
                },
                validator: (value) {
                  if (value == null) return 'Veuillez sélectionner un type';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ID du produit (lecture seule si modifié)
              TextFormField(
                controller: _productIdController,
                decoration: const InputDecoration(
                  labelText: 'ID du produit',
                  border: OutlineInputBorder(),
                ),
                readOnly: isProductLocked,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un ID de produit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nom du produit
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom de produit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantité
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une quantité';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'La quantité doit être un nombre positif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Référence
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Référence (facultatif)',
                  hintText: 'N° de bon, facture, etc.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Emplacement
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Emplacement',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez spécifier un emplacement';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _movementDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_movementDate),
                    );

                    if (time != null) {
                      setState(() {
                        _movementDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date et heure',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_movementDate.day}/${_movementDate.month}/${_movementDate.year} ${_movementDate.hour}:${_movementDate.minute.toString().padLeft(2, '0')}',
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (facultatif)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveMovement,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Mettre à jour' : 'Enregistrer'),
        ),
      ],
    );
  }

  String _getTypeLabel(StockMovementType type) {
    switch (type) {
      case StockMovementType.entry:
        return 'Entrée en stock';
      case StockMovementType.exit:
        return 'Sortie de stock';
      case StockMovementType.initial:
        return 'Stock initial';
      case StockMovementType.adjustment:
        return 'Ajustement de stock';
      default:
        return type.toString().split('.').last;
    }
  }
}
