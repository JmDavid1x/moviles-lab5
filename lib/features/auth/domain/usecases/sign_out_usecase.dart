import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';

/// Cierra la sesión en Supabase (no solo en la pantalla).
class SignOutUseCase {
  SignOutUseCase(this._auth);

  final AuthRepository _auth;

  Future<void> call() => _auth.signOut();
}
