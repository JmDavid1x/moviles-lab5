/// Error del dominio. El [message] ya viene en español, listo para la UI.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
