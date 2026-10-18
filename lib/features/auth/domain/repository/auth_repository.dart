import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';

/// Contrato de la cuenta (correo + contraseña).
abstract class AuthRepository {
  Future<AuthUser> signUp({required String email, required String password});

  Future<AuthUser> signIn({required String email, required String password});

  /// Lo usa el logout y también los casos de uso para limpiar si algo falla.
  Future<void> signOut();
}
