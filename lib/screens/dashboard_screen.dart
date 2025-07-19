import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:red_llantera_app/screens/login_screen.dart';
import 'package:red_llantera_app/screens/qr_scanner_screen.dart';
import 'package:red_llantera_app/screens/inventory_search_screen.dart';
import 'package:red_llantera_app/screens/network_screen.dart';
import 'package:red_llantera_app/utils/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabase = Supabase.instance.client;
  String _userName = 'Operador';
  String _businessName = 'Llantera';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // TODO: Cargar datos del usuario desde Supabase
      // Ejemplo:
      // final userData = await _supabase
      //     .from('clientes')
      //     .select()
      //     .eq('id_cliente', userId)
      //     .single();
      
      // setState(() {
      //   _userName = userData['nombre_responsable'] ?? 'Operador';
      //   _businessName = userData['nombre_negocio'] ?? 'Llantera';
      // });

      // Por ahora, usamos datos de ejemplo
      setState(() {
        _userName = 'Juan Pérez';
        _businessName = 'Llantera El Camino';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar datos del usuario: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Red Llantera Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado con saludo
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                _userName.isNotEmpty
                                    ? _userName[0].toUpperCase()
                                    : 'O',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hola, $_userName',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _businessName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Acciones principales
                    const Text(
                      'Acciones rápidas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grid de acciones
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Escanear QR
                        _buildActionCard(
                          icon: Icons.qr_code_scanner,
                          title: 'Escanear QR',
                          subtitle: 'Escanea el código QR de una llanta',
                          color: AppTheme.primaryColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QrScannerScreen(),
                              ),
                            );
                          },
                        ),

                        // Buscar inventario
                        _buildActionCard(
                          icon: Icons.search,
                          title: 'Buscar',
                          subtitle: 'Busca llantas por medida o marca',
                          color: AppTheme.secondaryColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InventorySearchScreen(),
                              ),
                            );
                          },
                        ),

                        // Red Llantera
                        _buildActionCard(
                          icon: Icons.people_alt_outlined,
                          title: 'Red Llantera',
                          subtitle: 'Busca llantas en la red de socios',
                          color: AppTheme.accentColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NetworkScreen(),
                              ),
                            );
                          },
                        ),

                        // Ventas recientes
                        _buildActionCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Ventas',
                          subtitle: 'Revisa las ventas recientes',
                          color: Colors.purple,
                          onTap: () {
                            // TODO: Implementar pantalla de ventas
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Próximamente disponible'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Estadísticas (a implementar en el futuro)
                    const Text(
                      'Estadísticas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tarjetas de estadísticas
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Llantas',
                            value: '124',
                            subtitle: 'En inventario',
                            icon: Icons.tire_repair,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Ventas',
                            value: '8',
                            subtitle: 'Hoy',
                            icon: Icons.attach_money,
                            color: AppTheme.accentColor,
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

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}