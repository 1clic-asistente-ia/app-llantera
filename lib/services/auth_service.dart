import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:red_llantera_app/constants/app_constants.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener el usuario actual
  User? get currentUser => _supabase.auth.currentUser;

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => currentUser != null;

  // Iniciar sesión con correo y contraseña
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Error en signInWithEmail: $e');
      rethrow;
    }
  }

  // Registrar un nuevo usuario
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      // Si el registro es exitoso y tenemos datos adicionales, los guardamos en la tabla de clientes
      if (response.user != null && userData != null) {
        await _supabase.from(AppConstants.clientesTable).insert({
          'id_cliente': response.user!.id,
          ...userData,
        });
      }

      return response;
    } catch (e) {
      debugPrint('Error en signUpWithEmail: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error en signOut: $e');
      rethrow;
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('Error en resetPassword: $e');
      rethrow;
    }
  }

  // Actualizar contraseña
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      debugPrint('Error en updatePassword: $e');
      rethrow;
    }
  }

  // Obtener datos del usuario actual desde la tabla de clientes
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      if (!isAuthenticated) return null;

      final response = await _supabase
          .from(AppConstants.clientesTable)
          .select()
          .eq('id_cliente', currentUser!.id)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error en getCurrentUserData: $e');
      return null;
    }
  }

  // Actualizar datos del usuario
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    try {
      if (!isAuthenticated) throw Exception('Usuario no autenticado');

      await _supabase
          .from(AppConstants.clientesTable)
          .update(userData)
          .eq('id_cliente', currentUser!.id);
    } catch (e) {
      debugPrint('Error en updateUserData: $e');
      rethrow;
    }
  }

  // Escuchar cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}