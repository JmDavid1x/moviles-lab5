import 'package:moviles_auth/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';

/// Cumple el contrato delegando todo en [SupabaseAuthDataSource].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._fuente);

  final SupabaseAuthDataSource _fuente;

  @override
  Future<AuthUser> signUp({required String email, required String password}) =>
      _fuente.signUp(email: email, password: password);

  @override
  Future<AuthUser> signIn({required String email, required String password}) =>
      _fuente.signIn(email: email, password: password);

  @override
  Future<void> signOut() => _fuente.signOut();
}
