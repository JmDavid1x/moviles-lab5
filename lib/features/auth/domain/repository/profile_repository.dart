import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// Contrato del perfil (username + nombre completo).
abstract class ProfileRepository {
  Future<void> createProfile(Profile profile);

  Future<Profile> getProfile(String id);
}
