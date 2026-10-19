import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';

import '../../../fakes/repositorios_falsos.dart';

void main() {
  late List<String> calls;

  setUp(() => calls = []);

  test('crea la cuenta primero y luego el perfil con su id', () async {
    final auth = AuthFalso(calls);
    final profiles = PerfilesFalso(calls);
    final signUp = SignUpUseCase(auth, profiles);

    final profile = await signUp(
      username: ' ana ',
      fullName: 'Ana Gómez ',
      email: ' ana@icesi.edu.co',
      password: ' 123456',
    );

    expect(calls, ['signUp', 'createProfile']);
    expect(profile.id, 'uid-123');
    expect(profile.username, 'ana');
    expect(profile.fullName, 'Ana Gómez');
    expect(profiles.rows['uid-123'], same(profile));
  });

  test('si falla signUp relanza el error y no crea el perfil', () async {
    final auth = AuthFalso(
      calls,
      signUpError: const AuthFailure('Ese correo ya está registrado'),
    );
    final signUp = SignUpUseCase(auth, PerfilesFalso(calls));

    await expectLater(
      signUp(
        username: 'ana',
        fullName: 'Ana Gómez',
        email: 'ana@icesi.edu.co',
        password: '123456',
      ),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          'Ese correo ya está registrado',
        ),
      ),
    );
    expect(calls, ['signUp']);
  });

  test('si falla createProfile cierra sesión y lanza AuthFailure', () async {
    final auth = AuthFalso(calls, signOutError: Exception('offline'));
    final profiles = PerfilesFalso(
      calls,
      createError: Exception('permission denied for table profiles'),
    );
    final signUp = SignUpUseCase(auth, profiles);

    await expectLater(
      signUp(
        username: 'ana',
        fullName: 'Ana Gómez',
        email: 'ana@icesi.edu.co',
        password: '123456',
      ),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          'Tu cuenta se creó, pero no pudimos guardar tu perfil. '
              'Intenta de nuevo.',
        ),
      ),
    );
    expect(calls, ['signUp', 'createProfile', 'signOut']);
  });
}
