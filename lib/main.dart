import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviles_auth/features/auth/data/repository/auth_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/repository/profile_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:moviles_auth/features/auth/data/source/supabase_profile_data_source.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/home/ui/screens/home_screen.dart';
import 'package:moviles_auth/features/login/ui/screens/login_screen.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';
import 'package:moviles_auth/features/register/ui/screens/register_screen.dart';
import 'package:moviles_auth/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(josedavid): poner la Project URL y la publishable key del proyecto
  // (Supabase > Project Settings > API). La service_role NO va en la app.
  await Supabase.initialize(
    url: 'TU_URL',
    publishableKey: 'TU_PUBLISHABLE_KEY',
  );

  runApp(const App());
}

/// Raíz de la app: tema y rutas con nombre.
///
/// Los casos de uso son opcionales para que las pruebas inyecten fakes.
/// Si llegan en null, cada ruta arma la cadena real sobre Supabase:
/// DataSource -> RepositoryImpl -> UseCase -> Bloc.
class App extends StatelessWidget {
  final SignUpUseCase? signUp;

  const App({super.key, this.signUp});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moviles Auth',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => BlocProvider(
          create: (_) => RegisterBloc(
            signUp ??
                SignUpUseCase(
                  AuthRepositoryImpl(
                    SupabaseAuthDataSource(Supabase.instance.client),
                  ),
                  ProfileRepositoryImpl(
                    SupabaseProfileDataSource(Supabase.instance.client),
                  ),
                ),
          ),
          child: const RegisterScreen(),
        ),
        // Home recibe un record (profile, email) desde login o registro.
        '/home': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as ({Profile profile, String email});
          return HomeScreen(
            username: args.profile.username,
            fullName: args.profile.fullName,
            email: args.email,
          );
        },
      },
    );
  }
}
