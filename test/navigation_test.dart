import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/main.dart';

import 'fakes/repositorios_falsos.dart';

/// Arma [App] con repositorios falsos en vez de Supabase.
App _app(List<String> calls, {AuthFalso? auth}) {
  final authRepository = auth ?? AuthFalso(calls);
  final profiles = PerfilesFalso(calls);
  return App(
    signUp: SignUpUseCase(authRepository, profiles),
    signIn: SignInUseCase(authRepository, profiles),
    signOut: SignOutUseCase(authRepository),
  );
}

void main() {
  testWidgets('login lleva al perfil y cerrar sesión vuelve al login', (
    tester,
  ) async {
    final calls = <String>[];
    // Primero registramos para que el fake tenga una fila que cargar.
    final auth = AuthFalso(calls);
    final app = _app(calls, auth: auth);
    await app.signUp!(
      username: 'ana',
      fullName: 'Ana Gómez',
      email: 'ana@icesi.edu.co',
      password: '123456',
    );
    calls.clear();

    await tester.pumpWidget(app);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pump();
    expect(find.text('Escribe tu correo y tu contraseña'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'ana@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Ana Gómez'), findsWidgets);
    expect(find.text('ana@icesi.edu.co'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(calls, ['signIn', 'getProfile', 'signOut']);
  });

  testWidgets('login muestra el error y se queda en el formulario', (
    tester,
  ) async {
    final calls = <String>[];
    await tester.pumpWidget(_app(calls));

    // El fake no tiene perfiles, así que el login falla en getProfile.
    await tester.enterText(find.byType(TextField).at(0), 'ana@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Tu cuenta no tiene perfil.'), findsOneWidget);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('registro rechaza contraseñas distintas', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(_app(calls));
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'ana');
    await tester.enterText(find.byType(TextField).at(1), 'Ana Gómez');
    await tester.enterText(find.byType(TextField).at(2), 'ana@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(3), '123456');
    await tester.enterText(find.byType(TextField).at(4), '654321');
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Registrarme'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Registrarme'));
    await tester.pump();
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(calls, isEmpty);

    await tester.enterText(find.byType(TextField).at(4), '123456');
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Registrarme'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Registrarme'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('@ana'), findsOneWidget);
    expect(find.text('ana@icesi.edu.co'), findsOneWidget);
    expect(calls, ['signUp', 'createProfile']);
  });

  testWidgets('registro muestra el error del caso de uso y se queda', (
    tester,
  ) async {
    final calls = <String>[];
    await tester.pumpWidget(
      _app(calls, auth: AuthFalso(calls, signUpError: Exception('boom'))),
    );
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.enterText(
        find.byType(TextField).at(i),
        i == 2 ? 'ana@icesi.edu.co' : (i >= 3 ? '123456' : 'ana'),
      );
    }
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Registrarme'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Registrarme'));
    await tester.pumpAndSettle();

    expect(find.text('Algo salió mal. Intenta de nuevo.'), findsOneWidget);
    expect(find.text('Crea tu cuenta'), findsOneWidget);
  });
}
