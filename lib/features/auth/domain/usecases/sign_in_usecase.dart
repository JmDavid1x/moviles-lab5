import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Inicio de sesión en dos pasos: la sesión y después el perfil de ese UID.
class SignInUseCase {
  SignInUseCase(this._auth, this._profiles);

  final AuthRepository _auth;
  final ProfileRepository _profiles;

  Future<({Profile profile, String email})> call({
    required String email,
    required String password,
  }) async {
    final cuenta = await _auth.signIn(email: email.trim(), password: password);

    try {
      final perfil = await _profiles.getProfile(cuenta.id);
      return (profile: perfil, email: cuenta.email);
    } catch (error) {
      // Sin perfil no hay Home: cerramos la sesión antes de avisar.
      try {
        await _auth.signOut();
      } catch (_) {}
      throw error is AuthFailure
          ? error
          : const AuthFailure('No pudimos cargar tu perfil. Intenta de nuevo.');
    }
  }
}
