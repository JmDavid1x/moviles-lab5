/// Datos públicos del usuario guardados en la tabla `profiles`.
///
/// Comparte el [id] con la cuenta de Auth. No lleva contraseña ni correo.
class Profile {
  const Profile({
    required this.id,
    required this.username,
    required this.fullName,
  });

  final String id;
  final String username;
  final String fullName;
}
