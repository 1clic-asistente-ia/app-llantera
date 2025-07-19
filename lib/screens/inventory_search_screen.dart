import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:red_llantera_app/models/tire.dart';
import 'package:red_llantera_app/screens/tire_detail_screen.dart';
import 'package:red_llantera_app/utils/app_theme.dart';

class InventorySearchScreen extends StatefulWidget {
  const InventorySearchScreen({super.key});

  @override
  State<InventorySearchScreen> createState() => _InventorySearchScreenState();
}

class _InventorySearchScreenState extends State<InventorySearchScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _hasSearched = false;
  List<Tire> _searchResults = [];
  String _searchType = 'medida'; // 'medida' o 'marca'
  List<String> _availableBrands = [];
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    try {
      final response = await _supabase
          .from('marcas')
          .select('nombre')
          .order('nombre');

      setState(() {
        _availableBrands = List<String>.from(
            response.map((brand) => brand['nombre'] as String));
      });
    } catch (e) {
      debugPrint('Error al cargar marcas: $e');
    }
  }

  Future<void> _searchInventory() async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      late final List<Map<String, dynamic>> response;

      if (_searchType == 'medida') {
        // Búsqueda por medida
        final searchTerm = _searchController.text.trim();
        response = await _supabase
            .from('inventario')
            .select('*, marcas(nombre)')
            .ilike('medida', '%$searchTerm%')
            .order('medida');
      } else {
        // Búsqueda por marca
        if (_selectedBrand == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        response = await _supabase
            .from('inventario')
            .select('*, marcas(nombre)')
            .eq('marcas.nombre', _selectedBrand)
            .order('medida');
      }

      final tires = response.map((data) => Tire.fromJson(data)).toList();

      setState(() {
        _searchResults = tires;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error en la búsqueda: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al realizar la búsqueda'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Inventario'),
      ),
      body: Column(
        children: [
          // Sección de búsqueda
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selector de tipo de búsqueda
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Por medida'),
                            value: 'medida',
                            groupValue: _searchType,
                            onChanged: (value) {
                              setState(() {
                                _searchType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Por marca'),
                            value: 'marca',
                            groupValue: _searchType,
                            onChanged: (value) {
                              setState(() {
                                _searchType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Campo de búsqueda (cambia según el tipo seleccionado)
                    if (_searchType == 'medida') ...[  
                      TextFormField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Medida de llanta',
                          hintText: 'Ej: 195/65R15',
                          prefixIcon: Icon(Icons.search),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa una medida';
                          }
                          return null;
                        },
                      ),
                    ] else ...[  
                      DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          prefixIcon: Icon(Icons.branding_watermark),
                        ),
                        items: _availableBrands.map((brand) {
                          return DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBrand = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor selecciona una marca';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Botón de búsqueda
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchInventory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Buscar'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Resultados de la búsqueda
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched && _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron resultados',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final tire = _searchResults[index];
                          return _buildTireCard(tire);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTireCard(Tire tire) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TireDetailScreen(tireId: tire.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen o placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: tire.photoUrl != null && tire.photoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          tire.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.tire_repair,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.tire_repair,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 16),
              // Información de la llanta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tire.brand} ${tire.size}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Condición: ${tire.condition ?? "No especificada"}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profundidad: ${tire.depth} mm',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Precio
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${tire.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}