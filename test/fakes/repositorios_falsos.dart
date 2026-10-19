import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Fakes escritos a mano. Anotan cada llamada en la lista compartida [calls]
/// para poder revisar el orden entre los dos repositorios.
class AuthFalso implements AuthRepository {
  final List<String> calls;
  final AuthUser user;
  final Object? signUpError;
  final Object? signInError;
  final Object? signOutError;

  AuthFalso(
    this.calls, {
    this.user = const AuthUser(id: 'uid-123', email: 'ana@icesi.edu.co'),
    this.signUpError,
    this.signInError,
    this.signOutError,
  });

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    calls.add('signUp');
    if (signUpError != null) throw signUpError!;
    return AuthUser(id: user.id, email: email);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    calls.add('signIn');
    if (signInError != null) throw signInError!;
    return user;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    if (signOutError != null) throw signOutError!;
  }
}

class PerfilesFalso implements ProfileRepository {
  final List<String> calls;
  final Object? createError;
  final Object? getError;
  final Map<String, Profile> rows = {};

  PerfilesFalso(this.calls, {this.createError, this.getError});

  @override
  Future<void> createProfile(Profile profile) async {
    calls.add('createProfile');
    if (createError != null) throw createError!;
    rows[profile.id] = profile;
  }

  @override
  Future<Profile> getProfile(String id) async {
    calls.add('getProfile');
    if (getError != null) throw getError!;
    final profile = rows[id];
    if (profile == null) throw const AuthFailure('Tu cuenta no tiene perfil.');
    return profile;
  }
}
