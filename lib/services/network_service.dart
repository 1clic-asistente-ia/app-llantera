import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:red_llantera_app/constants/app_constants.dart';

class NetworkService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener todas las llanteras en la red
  Future<List<Map<String, dynamic>>> getAllNetworkShops() async {
    try {
      final response = await _supabase
          .from(AppConstants.clientesTable)
          .select()
          .eq('visible_en_red', true)
          .order('nombre_negocio');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error en getAllNetworkShops: $e');
      return [];
    }
  }

  // Obtener llanteras favoritas del usuario actual
  Future<List<Map<String, dynamic>>> getFavoriteShops() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from(AppConstants.redFavoritosTable)
          .select('*, cliente_favorito:id_cliente_favorito(*)') // Unión con la tabla de clientes
          .eq('id_cliente', userId);

      // Transformar la respuesta para obtener los datos de la llantera favorita
      return response.map<Map<String, dynamic>>((item) {
        final shopData = item['cliente_favorito'] as Map<String, dynamic>;
        return {
          'id_favorito': item['id_favorito'],
          'fecha_agregado': item['fecha_agregado'],
          ...shopData,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error en getFavoriteShops: $e');
      return [];
    }
  }

  // Agregar una llantera a favoritos
  Future<bool> addShopToFavorites(String shopId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Verificar si ya está en favoritos
      final existing = await _supabase
          .from(AppConstants.redFavoritosTable)
          .select()
          .eq('id_cliente', userId)
          .eq('id_cliente_favorito', shopId);

      if (existing.isNotEmpty) {
        // Ya está en favoritos
        return true;
      }

      // Agregar a favoritos
      await _supabase.from(AppConstants.redFavoritosTable).insert({
        'id_cliente': userId,
        'id_cliente_favorito': shopId,
        'fecha_agregado': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error en addShopToFavorites: $e');
      return false;
    }
  }

  // Eliminar una llantera de favoritos
  Future<bool> removeShopFromFavorites(String shopId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from(AppConstants.redFavoritosTable)
          .delete()
          .eq('id_cliente', userId)
          .eq('id_cliente_favorito', shopId);

      return true;
    } catch (e) {
      debugPrint('Error en removeShopFromFavorites: $e');
      return false;
    }
  }

  // Buscar llantas en la red por medida
  Future<List<Map<String, dynamic>>> searchNetworkTiresBySize(
      String size, {bool onlyFavorites = false}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Construir la consulta base
      var query = _supabase.rpc(
        'search_network_tires_by_size',
        params: {
          'p_medida': size,
          'p_id_cliente': userId,
        },
      );

      // Si solo queremos buscar en favoritos
      if (onlyFavorites) {
        query = query.eq('is_favorite', true);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error en searchNetworkTiresBySize: $e');
      return [];
    }
  }

  // Buscar llantas en la red por marca
  Future<List<Map<String, dynamic>>> searchNetworkTiresByBrand(
      String brandName, {bool onlyFavorites = false}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Construir la consulta base
      var query = _supabase.rpc(
        'search_network_tires_by_brand',
        params: {
          'p_marca': brandName,
          'p_id_cliente': userId,
        },
      );

      // Si solo queremos buscar en favoritos
      if (onlyFavorites) {
        query = query.eq('is_favorite', true);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error en searchNetworkTiresByBrand: $e');
      return [];
    }
  }

  // Obtener detalles de una llantera específica
  Future<Map<String, dynamic>?> getShopDetails(String shopId) async {
    try {
      final response = await _supabase
          .from(AppConstants.clientesTable)
          .select()
          .eq('id_cliente', shopId)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error en getShopDetails: $e');
      return null;
    }
  }

  // Verificar si una llantera está en favoritos
  Future<bool> isShopFavorite(String shopId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from(AppConstants.redFavoritosTable)
          .select()
          .eq('id_cliente', userId)
          .eq('id_cliente_favorito', shopId);

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Error en isShopFavorite: $e');
      return false;
    }
  }
}