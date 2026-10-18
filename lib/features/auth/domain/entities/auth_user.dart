/// Cuenta autenticada tal como la ve la app: solo su UID y su correo.
class AuthUser {
  const AuthUser({required this.id, required this.email});

  final String id;
  final String email;
}
