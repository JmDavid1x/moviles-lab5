import 'package:moviles_auth/features/auth/data/source/supabase_profile_data_source.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Cumple el contrato delegando todo en [SupabaseProfileDataSource].
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._fuente);

  final SupabaseProfileDataSource _fuente;

  @override
  Future<void> createProfile(Profile profile) => _fuente.createProfile(profile);

  @override
  Future<Profile> getProfile(String id) => _fuente.getProfile(id);
}
