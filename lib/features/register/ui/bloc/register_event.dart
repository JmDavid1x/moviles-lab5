/// Lo que la pantalla de registro le puede pedir al Bloc.
abstract class RegisterEvent {}

/// El usuario tocó "Registrarme" y las validaciones locales pasaron.
class RegisterSubmitted extends RegisterEvent {
  RegisterSubmitted({
    required this.username,
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String username;
  final String fullName;
  final String email;
  final String password;
}
