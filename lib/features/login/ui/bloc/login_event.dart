/// Lo que la pantalla de login le puede pedir al Bloc.
abstract class LoginEvent {}

/// El usuario tocó "Iniciar sesión" con ambos campos llenos.
class LoginSubmitted extends LoginEvent {
  LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;
}
