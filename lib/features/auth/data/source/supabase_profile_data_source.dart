import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';

/// Único punto que conoce la tabla `profiles`.
///
/// Aquí vive la traducción `fullName` (Dart) ↔ `full_name` (columna).
class SupabaseProfileDataSource {
  SupabaseProfileDataSource(this._client);

  final SupabaseClient _client;

  static const _tabla = 'profiles';

  Future<void> createProfile(Profile profile) async {
    try {
      await _client.from(_tabla).insert(_aFila(profile));
    } on PostgrestException catch (e) {
      throw AuthFailure(_mensaje(e));
    }
  }

  Future<Profile> getProfile(String id) async {
    try {
      final fila = await _client.from(_tabla).select().eq('id', id).single();
      return _aPerfil(fila);
    } on PostgrestException catch (e) {
      // PGRST116: `.single()` no encontró ninguna fila.
      throw AuthFailure(
        e.code == 'PGRST116' ? 'Tu cuenta no tiene perfil.' : _mensaje(e),
      );
    }
  }

  Map<String, dynamic> _aFila(Profile p) => {
    'id': p.id,
    'username': p.username,
    'full_name': p.fullName,
  };

  Profile _aPerfil(Map<String, dynamic> fila) => Profile(
    id: fila['id'] as String,
    username: fila['username'] as String,
    fullName: fila['full_name'] as String,
  );

  // 42501 = "permission denied for table profiles": falta el grant.
  String _mensaje(PostgrestException e) => e.code == '42501'
      ? 'Sin permiso sobre la tabla profiles (revisa el grant).'
      : 'Error en la tabla profiles: ${e.message}';
}
