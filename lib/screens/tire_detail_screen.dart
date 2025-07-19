import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:red_llantera_app/utils/app_theme.dart';
import 'package:red_llantera_app/models/tire.dart';
import 'package:red_llantera_app/widgets/photo_capture_widget.dart';

class TireDetailScreen extends StatefulWidget {
  final String tireId;

  const TireDetailScreen({super.key, required this.tireId});

  @override
  State<TireDetailScreen> createState() => _TireDetailScreenState();
}

class _TireDetailScreenState extends State<TireDetailScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  Tire? _tire;

  @override
  void initState() {
    super.initState();
    _loadTireData();
  }

  Future<void> _loadTireData() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });

      // Consultar la información de la llanta en Supabase
      final response = await _supabase
          .from('inventario')
          .select('*, marcas(nombre)')
          .eq('id_llanta', widget.tireId)
          .single();

      // Crear objeto Tire con los datos
      final tire = Tire.fromJson(response);

      setState(() {
        _tire = tire;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar datos de la llanta: $e');
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'No se pudo cargar la información de la llanta';
      });
    }
  }

  Future<void> _updateTirePhoto(String photoUrl) async {
    try {
      // Actualizar la URL de la foto en Supabase
      await _supabase
          .from('inventario')
          .update({'foto_url': photoUrl})
          .eq('id_llanta', widget.tireId);

      // Actualizar el estado local
      setState(() {
        if (_tire != null) {
          _tire = _tire!.copyWith(photoUrl: photoUrl);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto actualizada correctamente')),
        );
      }
    } catch (e) {
      debugPrint('Error al actualizar la foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar la foto'),
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
        title: const Text('Detalle de Llanta'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadTireData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta principal con foto y datos básicos
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto de la llanta
                            GestureDetector(
                              onTap: () {
                                // Mostrar diálogo para tomar foto
                                showDialog(
                                  context: context,
                                  builder: (context) => PhotoCaptureWidget(
                                    onPhotoTaken: (photoUrl) {
                                      _updateTirePhoto(photoUrl);
                                    },
                                    tireId: widget.tireId,
                                  ),
                                );
                              },
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                                child: _tire?.photoUrl != null &&
                                        _tire!.photoUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                        child: Image.network(
                                          _tire!.photoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              _buildAddPhotoPlaceholder(),
                                        ),
                                      )
                                    : _buildAddPhotoPlaceholder(),
                              ),
                            ),

                            // Información básica
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${_tire?.brand ?? "Sin marca"} ${_tire?.size ?? ""}',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
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
                                          '\$${_tire?.price.toStringAsFixed(2) ?? "0.00"}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ID: ${widget.tireId}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow('Medida', _tire?.size ?? 'No disponible'),
                                  _buildInfoRow('Marca', _tire?.brand ?? 'No disponible'),
                                  _buildInfoRow(
                                      'Condición', _tire?.condition ?? 'No disponible'),
                                  _buildInfoRow('Dot', _tire?.dot ?? 'No disponible'),
                                  _buildInfoRow(
                                      'Profundidad', '${_tire?.depth ?? "N/A"} mm'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sección de detalles adicionales
                      const Text(
                        'Detalles adicionales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                  'Ubicación', _tire?.location ?? 'No especificada'),
                              _buildInfoRow('Tipo', _tire?.type ?? 'No especificado'),
                              _buildInfoRow(
                                  'Fecha de ingreso', _tire?.entryDate ?? 'No disponible'),
                              _buildInfoRow('Notas', _tire?.notes ?? 'Sin notas'),
                            ],
                          ),
                        ),
                      ),

                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implementar funcionalidad de venta
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Próximamente disponible'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Vender'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implementar funcionalidad de reserva
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Próximamente disponible'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.bookmark_border),
                              label: const Text('Reservar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAddPhotoPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 50,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Toca para agregar foto',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}