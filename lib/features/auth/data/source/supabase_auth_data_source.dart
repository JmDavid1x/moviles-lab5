import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';

/// Único punto de la app que habla con Supabase Auth.
///
/// Traduce las excepciones del SDK a [AuthFailure] con mensajes en español.
class SupabaseAuthDataSource {
  SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  static const _sinRed = AuthFailure('Sin conexión. Revisa tu internet.');

  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final respuesta = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return _aAuthUser(respuesta.user, email, 'No se pudo crear la cuenta');
    } on AuthRetryableFetchException {
      throw _sinRed;
    } on AuthException catch (e) {
      throw AuthFailure(_mensajeRegistro(e));
    }
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final respuesta = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _aAuthUser(respuesta.user, email, 'No se pudo iniciar sesión');
    } on AuthRetryableFetchException {
      throw _sinRed;
    } on AuthException catch (e) {
      throw AuthFailure(_mensajeLogin(e));
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  // Nunca usamos `user!`: si Supabase no devuelve usuario, es un error claro.
  AuthUser _aAuthUser(User? user, String email, String siFalta) {
    if (user == null) throw AuthFailure(siFalta);
    return AuthUser(id: user.id, email: user.email ?? email);
  }

  String _mensajeRegistro(AuthException e) {
    final texto = e.message.toLowerCase();
    return switch (e.code) {
      'user_already_exists' ||
      'email_exists' => 'Ese correo ya está registrado',
      'weak_password' => 'La contraseña debe tener al menos 6 caracteres',
      'email_address_invalid' ||
      'validation_failed' => 'El correo no es válido',
      _ when texto.contains('already registered') =>
        'Ese correo ya está registrado',
      _
          when e is AuthWeakPasswordException ||
              texto.contains('password should be') =>
        'La contraseña debe tener al menos 6 caracteres',
      _ when texto.contains('invalid format') || texto.contains('is invalid') =>
        'El correo no es válido',
      _ => 'No pudimos crear tu cuenta: ${e.message}',
    };
  }

  String _mensajeLogin(AuthException e) {
    final texto = e.message.toLowerCase();
    return switch (e.code) {
      'email_not_confirmed' => 'Confirma tu correo antes de entrar',
      'invalid_credentials' => 'Correo o contraseña incorrectos',
      _ when texto.contains('not confirmed') =>
        'Confirma tu correo antes de entrar',
      _ when texto.contains('invalid login credentials') =>
        'Correo o contraseña incorrectos',
      _ => 'No pudimos iniciar sesión: ${e.message}',
    };
  }
}
