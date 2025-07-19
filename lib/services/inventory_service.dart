import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:red_llantera_app/constants/app_constants.dart';
import 'package:red_llantera_app/models/tire.dart';

class InventoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener una llanta por su ID
  Future<Tire?> getTireById(String tireId) async {
    try {
      final response = await _supabase
          .from(AppConstants.inventarioTable)
          .select('*, marcas(nombre)')
          .eq('id_llanta', tireId)
          .single();

      return Tire.fromJson(response);
    } catch (e) {
      debugPrint('Error en getTireById: $e');
      return null;
    }
  }

  // Buscar llantas por medida
  Future<List<Tire>> searchTiresBySize(String size) async {
    try {
      final response = await _supabase
          .from(AppConstants.inventarioTable)
          .select('*, marcas(nombre)')
          .ilike('medida', '%$size%')
          .order('medida')
          .limit(AppConstants.maxSearchResults);

      return response.map((data) => Tire.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error en searchTiresBySize: $e');
      return [];
    }
  }

  // Buscar llantas por marca
  Future<List<Tire>> searchTiresByBrand(String brandName) async {
    try {
      final response = await _supabase
          .from(AppConstants.inventarioTable)
          .select('*, marcas(nombre)')
          .eq('marcas.nombre', brandName)
          .order('medida')
          .limit(AppConstants.maxSearchResults);

      return response.map((data) => Tire.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error en searchTiresByBrand: $e');
      return [];
    }
  }

  // Obtener todas las marcas disponibles
  Future<List<String>> getAllBrands() async {
    try {
      final response = await _supabase
          .from(AppConstants.marcasTable)
          .select('nombre')
          .order('nombre');

      return List<String>.from(response.map((brand) => brand['nombre'] as String));
    } catch (e) {
      debugPrint('Error en getAllBrands: $e');
      return [];
    }
  }

  // Subir una foto de llanta
  Future<String?> uploadTirePhoto(File imageFile, String tireId) async {
    try {
      // Generar un nombre único para el archivo
      final fileName = 'tire_${tireId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'tires/$fileName';

      // Subir la imagen a Supabase Storage
      await _supabase.storage
          .from(AppConstants.tirePhotosBucket)
          .upload(filePath, imageFile);

      // Obtener la URL pública de la imagen
      final imageUrl = _supabase.storage
          .from(AppConstants.tirePhotosBucket)
          .getPublicUrl(filePath);

      // Actualizar la URL de la foto en la tabla de inventario
      await _supabase
          .from(AppConstants.inventarioTable)
          .update({'foto_url': imageUrl})
          .eq('id_llanta', tireId);

      return imageUrl;
    } catch (e) {
      debugPrint('Error en uploadTirePhoto: $e');
      return null;
    }
  }

  // Actualizar información de una llanta
  Future<bool> updateTire(String tireId, Map<String, dynamic> tireData) async {
    try {
      await _supabase
          .from(AppConstants.inventarioTable)
          .update(tireData)
          .eq('id_llanta', tireId);

      return true;
    } catch (e) {
      debugPrint('Error en updateTire: $e');
      return false;
    }
  }

  // Obtener medidas compatibles para una medida específica
  Future<List<String>> getCompatibleSizes(String size) async {
    try {
      final response = await _supabase
          .from(AppConstants.medidasCompatiblesTable)
          .select('medida_compatible')
          .eq('medida_original', size);

      return List<String>.from(
          response.map((item) => item['medida_compatible'] as String));
    } catch (e) {
      debugPrint('Error en getCompatibleSizes: $e');
      return [];
    }
  }

  // Obtener estadísticas básicas del inventario
  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      // Total de llantas en inventario
      final totalCount = await _supabase
          .from(AppConstants.inventarioTable)
          .count();

      // Contar por marca (top 5)
      final brandCounts = await _supabase
          .rpc('count_tires_by_brand')
          .limit(5);

      // Contar por medida (top 5)
      final sizeCounts = await _supabase
          .rpc('count_tires_by_size')
          .limit(5);

      return {
        'total': totalCount,
        'by_brand': brandCounts,
        'by_size': sizeCounts,
      };
    } catch (e) {
      debugPrint('Error en getInventoryStats: $e');
      return {
        'total': 0,
        'by_brand': [],
        'by_size': [],
      };
    }
  }
}