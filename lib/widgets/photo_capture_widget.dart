import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:red_llantera_app/utils/app_theme.dart';

class PhotoCaptureWidget extends StatefulWidget {
  final Function(String photoUrl) onPhotoTaken;
  final String tireId;

  const PhotoCaptureWidget({
    super.key,
    required this.onPhotoTaken,
    required this.tireId,
  });

  @override
  State<PhotoCaptureWidget> createState() => _PhotoCaptureWidgetState();
}

class _PhotoCaptureWidgetState extends State<PhotoCaptureWidget> {
  final _supabase = Supabase.instance.client;
  final _imagePicker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _takePicture() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _errorMessage = null;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      setState(() {
        _errorMessage = 'Por favor, selecciona o toma una foto primero';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Generar un nombre único para el archivo
      final fileName = 'tire_${widget.tireId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'tires/$fileName';

      // Subir la imagen a Supabase Storage
      await _supabase.storage
          .from('tire_photos')
          .upload(filePath, _imageFile!);

      // Obtener la URL pública de la imagen
      final imageUrl = _supabase.storage
          .from('tire_photos')
          .getPublicUrl(filePath);

      // Llamar al callback con la URL de la imagen
      widget.onPhotoTaken(imageUrl);

      // Cerrar el diálogo
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error al subir la imagen: $e');
      setState(() {
        _isUploading = false;
        _errorMessage = 'Error al subir la imagen. Inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Agregar foto de la llanta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_imageFile != null) ...[  
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _imageFile!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[  
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
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
                        'No hay imagen seleccionada',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_errorMessage != null) ...[  
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Subiendo...'),
                      ],
                    )
                  : const Text('Guardar foto'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isUploading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}