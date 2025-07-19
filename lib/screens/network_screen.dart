import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:red_llantera_app/utils/app_theme.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _networkShops = [];
  List<Map<String, dynamic>> _favoriteShops = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNetworkData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNetworkData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // En una implementación real, cargaríamos datos desde Supabase
      // Por ahora, usamos datos de ejemplo
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _networkShops = [
          {
            'id': '1',
            'nombre': 'Llantera El Camino',
            'direccion': 'Av. Revolución 123, Ciudad de México',
            'telefono': '55 1234 5678',
            'distancia': 2.5,
            'rating': 4.5,
            'inventario': 120,
          },
          {
            'id': '2',
            'nombre': 'Llantas Express',
            'direccion': 'Calzada Independencia 456, Guadalajara',
            'telefono': '33 8765 4321',
            'distancia': 5.1,
            'rating': 4.2,
            'inventario': 85,
          },
          {
            'id': '3',
            'nombre': 'Neumáticos del Norte',
            'direccion': 'Av. Universidad 789, Monterrey',
            'telefono': '81 2345 6789',
            'distancia': 8.7,
            'rating': 4.8,
            'inventario': 210,
          },
        ];

        _favoriteShops = [
          {
            'id': '3',
            'nombre': 'Neumáticos del Norte',
            'direccion': 'Av. Universidad 789, Monterrey',
            'telefono': '81 2345 6789',
            'distancia': 8.7,
            'rating': 4.8,
            'inventario': 210,
          },
        ];

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar datos de la red: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar datos de la red'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(String shopId) async {
    // En una implementación real, actualizaríamos en Supabase
    // Por ahora, solo actualizamos el estado local

    try {
      final isFavorite = _favoriteShops.any((shop) => shop['id'] == shopId);

      if (isFavorite) {
        // Eliminar de favoritos
        setState(() {
          _favoriteShops.removeWhere((shop) => shop['id'] == shopId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Eliminado de favoritos'),
            ),
          );
        }
      } else {
        // Agregar a favoritos
        final shop = _networkShops.firstWhere((shop) => shop['id'] == shopId);
        setState(() {
          _favoriteShops.add(shop);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agregado a favoritos'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al actualizar favoritos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar favoritos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showShopDetails(Map<String, dynamic> shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildShopDetailsSheet(shop),
    );
  }

  Widget _buildShopDetailsSheet(Map<String, dynamic> shop) {
    final isFavorite = _favoriteShops.any((s) => s['id'] == shop['id']);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con nombre y acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        shop['nombre'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      onPressed: () {
                        _toggleFavorite(shop['id']);
                        Navigator.pop(context);
                      },
                      tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Calificación
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < (shop['rating'] as num).floor()
                            ? Icons.star
                            : index < (shop['rating'] as num)
                                ? Icons.star_half
                                : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${shop['rating']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Información de contacto
                const Text(
                  'Información de contacto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, shop['direccion']),
                _buildInfoRow(Icons.phone, shop['telefono']),
                _buildInfoRow(
                    Icons.directions_car, '${shop['distancia']} km de distancia'),
                const SizedBox(height: 16),

                // Inventario
                const Text(
                  'Inventario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${shop['inventario']} llantas disponibles'),
                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar búsqueda en inventario de este negocio
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Próximamente disponible'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar llantas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar llamada telefónica
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Próximamente disponible'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Llamar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar navegación a Google Maps
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente disponible'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Cómo llegar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    final isFavorite = _favoriteShops.any((s) => s['id'] == shop['id']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showShopDetails(shop),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre y favorito
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      shop['nombre'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => _toggleFavorite(shop['id']),
                    tooltip:
                        isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Dirección
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      shop['direccion'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Distancia, calificación e inventario
              Row(
                children: [
                  // Distancia
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_car,
                            size: 12, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(
                          '${shop['distancia']} km',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Calificación
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${shop['rating']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Inventario
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.tire_repair,
                            size: 12, color: AppTheme.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '${shop['inventario']} llantas',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Red Llantera Digital'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Red completa'),
            Tab(text: 'Mis favoritos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de Red completa
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _networkShops.isEmpty
                  ? _buildEmptyState('No hay llanteras en la red')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _networkShops.length,
                      itemBuilder: (context, index) {
                        return _buildShopCard(_networkShops[index]);
                      },
                    ),

          // Pestaña de Favoritos
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favoriteShops.isEmpty
                  ? _buildEmptyState('No tienes llanteras favoritas')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _favoriteShops.length,
                      itemBuilder: (context, index) {
                        return _buildShopCard(_favoriteShops[index]);
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (message.contains('favoritas')) ...[  
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Explorar la red'),
            ),
          ],
        ],
      ),
    );
  }
}