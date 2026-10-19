import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

enum LoginStatus { initial, loading, success, failure }

/// Estado único del login. La contraseña nunca se guarda aquí.
class LoginState {
  const LoginState({
    this.status = LoginStatus.initial,
    this.profile,
    this.email,
    this.errorMessage,
  });

  final LoginStatus status;
  final Profile? profile;
  final String? email;
  final String? errorMessage;

  bool get isLoading => status == LoginStatus.loading;

  // Igual que en el registro: errorMessage no se hereda entre estados.
  LoginState copyWith({
    LoginStatus? status,
    Profile? profile,
    String? email,
    String? errorMessage,
  }) => LoginState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    email: email ?? this.email,
    errorMessage: errorMessage,
  );
}
