import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

enum RegisterStatus { initial, loading, success, failure }

/// Estado único del registro. La contraseña nunca se guarda aquí.
class RegisterState {
  const RegisterState({
    this.status = RegisterStatus.initial,
    this.profile,
    this.email,
    this.errorMessage,
  });

  final RegisterStatus status;
  final Profile? profile;

  /// Correo con el que se registró; Home lo necesita y Profile no lo tiene.
  final String? email;
  final String? errorMessage;

  bool get isLoading => status == RegisterStatus.loading;

  // OJO: errorMessage no se hereda. Cada estado nuevo arranca sin error
  // a menos que se pase uno explícito.
  RegisterState copyWith({
    RegisterStatus? status,
    Profile? profile,
    String? email,
    String? errorMessage,
  }) => RegisterState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    email: email ?? this.email,
    errorMessage: errorMessage,
  );
}
