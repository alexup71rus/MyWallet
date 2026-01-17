import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallet_card.dart';
import 'scanner_screen.dart';

class AddCardScreen extends StatefulWidget {
  final WalletCard? initialCard; // For linking support

  const AddCardScreen({super.key, this.initialCard});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.store_rounded;
  String _selectedCardType = 'Loyalty Card';

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  final List<String> _cardTypes = [
    'Loyalty Card',
    'Gift Card',
    'Membership Card',
    'Discount Card',
    'Club Card',
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    const Color(0xFF1E1E1E), // Black
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.deepOrange,
    Colors.lime,
    Colors.pinkAccent,
    Colors.blueGrey,
  ];

  final List<IconData> _icons = [
    Icons.store_rounded,
    Icons.shopping_bag,
    Icons.local_cafe,
    Icons.restaurant,
    Icons.fastfood,
    Icons.local_grocery_store,
    Icons.card_giftcard,
    Icons.fitness_center,
    Icons.flight,
    Icons.directions_car,
    Icons.pets,
    Icons.movie,
    Icons.sports_esports,
    Icons.local_pharmacy,
    Icons.local_gas_station,
    Icons.book,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCard != null) {
      _nameController.text = widget.initialCard!.name;
      _codeController.text = widget.initialCard!.code;
      if (widget.initialCard!.colorValue != 0) {
        _selectedColor = Color(widget.initialCard!.colorValue);
      }
      if (widget.initialCard!.iconPoint != null) {
        _selectedIcon = IconData(
          widget.initialCard!.iconPoint!,
          fontFamily: 'MaterialIcons',
        );
      }
      _selectedCardType = widget.initialCard!.cardType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview Card
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _selectedColor,
                      Color.lerp(_selectedColor, Colors.black, 0.2)!,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(_selectedIcon, color: Colors.white, size: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedCardType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.isEmpty
                              ? 'Store Name'
                              : _nameController.text,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _codeController.text.isEmpty
                              ? '0000 0000 0000'
                              : _codeController.text,
                          style: GoogleFonts.sourceCodePro(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Inputs
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  hintText: 'e.g. Starbucks, Tesco',
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCardType,
                decoration: InputDecoration(
                  labelText: 'Card Type',
                  prefixIcon: const Icon(Icons.label),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: _cardTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCardType = value!);
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Card Code',
                        hintText: 'Scan or enter code',
                        prefixIcon: const Icon(Icons.qr_code),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a code' : null,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _scanCode,
                    icon: const Icon(Icons.camera_alt),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Card Icon',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    final icon = _icons[index];
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Card Color',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors
                    .map(
                      (color) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _selectedColor == color
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 3,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _selectedColor == color
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
                child: const Text(
                  'Save Card',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );
    if (result != null) {
      setState(() {
        _codeController.text = result;
      });
    }
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final newCard = WalletCard(
        id:
            widget.initialCard?.id ??
            DateTime.now().millisecondsSinceEpoch.toString() +
                Random().nextInt(1000).toString(),
        code: _codeController.text,
        displayCode: _codeController.text,
        name: _nameController.text,
        colorValue: _selectedColor.toARGB32(),
        iconPoint: _selectedIcon.codePoint,
        dateAdded: widget.initialCard?.dateAdded ?? DateTime.now(),
        cardType: _selectedCardType,
      );
      Navigator.pop(context, newCard);
    }
  }
}
