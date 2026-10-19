import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';

import '../../../fakes/repositorios_falsos.dart';

void main() {
  late List<String> calls;

  setUp(() => calls = []);

  test('inicia sesión y después carga el perfil de ese usuario', () async {
    final profiles = PerfilesFalso(calls);
    profiles.rows['uid-123'] = const Profile(
      id: 'uid-123',
      username: 'ana',
      fullName: 'Ana Gómez',
    );
    final signIn = SignInUseCase(AuthFalso(calls), profiles);

    final result = await signIn(email: 'ana@icesi.edu.co', password: '123456');

    expect(calls, ['signIn', 'getProfile']);
    expect(result.profile.id, 'uid-123');
    expect(result.profile.username, 'ana');
    expect(result.email, 'ana@icesi.edu.co');
  });

  test('si falla signIn relanza el error y no busca el perfil', () async {
    final auth = AuthFalso(
      calls,
      signInError: const AuthFailure('Correo o contraseña incorrectos'),
    );
    final signIn = SignInUseCase(auth, PerfilesFalso(calls));

    await expectLater(
      signIn(email: 'ana@icesi.edu.co', password: 'mala'),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          'Correo o contraseña incorrectos',
        ),
      ),
    );
    expect(calls, ['signIn']);
  });

  test('si falla getProfile cierra sesión y lanza AuthFailure', () async {
    // Sin filas: el fake lanza 'Tu cuenta no tiene perfil.'
    final signIn = SignInUseCase(AuthFalso(calls), PerfilesFalso(calls));

    await expectLater(
      signIn(email: 'ana@icesi.edu.co', password: '123456'),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          'Tu cuenta no tiene perfil.',
        ),
      ),
    );
    expect(calls, ['signIn', 'getProfile', 'signOut']);
  });

  test('un error inesperado en getProfile se vuelve AuthFailure', () async {
    final signIn = SignInUseCase(
      AuthFalso(calls),
      PerfilesFalso(calls, getError: Exception('socket closed')),
    );

    await expectLater(
      signIn(email: 'ana@icesi.edu.co', password: '123456'),
      throwsA(isA<AuthFailure>()),
    );
    expect(calls.last, 'signOut');
  });
}
