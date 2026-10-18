import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Registro en dos pasos: primero la cuenta y luego el perfil con el mismo id.
class SignUpUseCase {
  SignUpUseCase(this._auth, this._profiles);

  final AuthRepository _auth;
  final ProfileRepository _profiles;

  static const _perfilFallido =
      'Tu cuenta se creó, pero no pudimos guardar tu perfil. Intenta de nuevo.';

  Future<Profile> call({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Si la cuenta falla, el AuthFailure de la capa de datos sube sin tocarlo.
    final cuenta = await _auth.signUp(email: email.trim(), password: password);

    final perfil = Profile(
      id: cuenta.id,
      username: username.trim(),
      fullName: fullName.trim(),
    );

    try {
      await _profiles.createProfile(perfil);
    } catch (_) {
      // Cuenta sin perfil: no dejamos la sesión abierta a medias.
      await _cerrarSesionSinFallar();
      throw const AuthFailure(_perfilFallido);
    }
    return perfil;
  }

  Future<void> _cerrarSesionSinFallar() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
