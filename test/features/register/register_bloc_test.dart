import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_event.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_state.dart';

import '../../fakes/repositorios_falsos.dart';

RegisterSubmitted _event() => RegisterSubmitted(
  username: 'ana',
  fullName: 'Ana Gómez',
  email: 'ana@icesi.edu.co',
  password: '123456',
);

void main() {
  test('arranca en initial', () {
    final bloc = RegisterBloc(SignUpUseCase(AuthFalso([]), PerfilesFalso([])));
    expect(bloc.state.status, RegisterStatus.initial);
    bloc.close();
  });

  test('emite loading y luego success con el perfil', () async {
    final calls = <String>[];
    final bloc = RegisterBloc(
      SignUpUseCase(AuthFalso(calls), PerfilesFalso(calls)),
    );

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.loading)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.success)
            .having((s) => s.profile?.id, 'profile.id', 'uid-123')
            .having((s) => s.profile?.username, 'username', 'ana')
            .having((s) => s.email, 'email', 'ana@icesi.edu.co'),
      ]),
    );
    bloc.add(_event());
    await expectation;
    await bloc.close();
  });

  test(
    'emite loading y luego failure con el mensaje del AuthFailure',
    () async {
      final calls = <String>[];
      final bloc = RegisterBloc(
        SignUpUseCase(
          AuthFalso(
            calls,
            signUpError: const AuthFailure('Ese correo ya está registrado'),
          ),
          PerfilesFalso(calls),
        ),
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RegisterState>().having(
            (s) => s.status,
            'status',
            RegisterStatus.loading,
          ),
          isA<RegisterState>()
              .having((s) => s.status, 'status', RegisterStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Ese correo ya está registrado',
              ),
        ]),
      );
      bloc.add(_event());
      await expectation;
      await bloc.close();
    },
  );

  test('un error inesperado muestra el mensaje genérico', () async {
    final calls = <String>[];
    final bloc = RegisterBloc(
      SignUpUseCase(
        AuthFalso(calls, signUpError: StateError('boom')),
        PerfilesFalso(calls),
      ),
    );

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Algo salió mal. Intenta de nuevo.',
        ),
      ]),
    );
    bloc.add(_event());
    await expectation;
    await bloc.close();
  });

  test('un nuevo envío limpia el error anterior', () async {
    final calls = <String>[];
    final bloc = RegisterBloc(
      SignUpUseCase(
        AuthFalso(calls, signUpError: const AuthFailure('x')),
        PerfilesFalso(calls),
      ),
    );
    bloc.add(_event());
    await bloc.stream.firstWhere((s) => s.status == RegisterStatus.failure);

    final loading = bloc.stream.first;
    bloc.add(_event());
    expect((await loading).errorMessage, isNull);
    await bloc.close();
  });
}
