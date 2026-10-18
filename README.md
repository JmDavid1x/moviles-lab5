# moviles-lab5 · Registro e inicio de sesión con Supabase

Laboratorio 5 de **Aplicaciones Móviles** (Universidad Icesi).
App Flutter con registro, login y cierre de sesión sobre Supabase, organizada con
Clean Architecture y Bloc.

> Desarrollado con asistencia de IA (Claude Code).

## Idea central

El formulario de registro pide cinco datos, pero van a dos destinos:

| Dato | Destino |
| --- | --- |
| Correo y contraseña | Supabase Auth (crea la cuenta y devuelve el UID) |
| Username y nombre completo | Tabla `profiles`, con ese mismo UID como `id` |
| Confirmar contraseña | No sale de la pantalla |

`SignUpUseCase` es la única pieza que conoce los dos destinos y decide el orden:
primero la cuenta, después el perfil. Si el perfil falla, cierra la sesión.

## Capas

```
lib/features/
├── auth/domain    entidades, AuthFailure, contratos y casos de uso (Dart puro)
├── auth/data      data sources de Supabase + implementaciones de los contratos
├── register/ui    RegisterBloc + RegisterScreen
├── login/ui       LoginBloc + LoginScreen
└── home/ui        HomeScreen (recibe el cierre de sesión como callback)
```

Solo `auth/data/source/*` y `main.dart` importan `supabase_flutter`.

## Puesta en marcha

1. En `lib/main.dart`, cambia `TU_URL` y `TU_PUBLISHABLE_KEY` por los de tu
   proyecto (Project Settings → API). Nunca uses la `service_role`.
2. Base de datos:

   ```bash
   npx supabase login
   npx supabase link --project-ref <tu-project-ref>
   npx supabase db push      # crea/ajusta public.profiles
   npx supabase config push  # confirmación de correo desactivada
   ```

3. App:

   ```bash
   flutter pub get
   flutter run
   ```

## Pruebas

```bash
flutter analyze
flutter test
```

- `test/features/auth/domain`: casos de uso con repositorios falsos (orden de llamadas y limpieza).
- `test/features/register`: estados del `RegisterBloc` (`loading → success` / `loading → failure`).
- `test/navigation_test.dart`: flujo de pantallas con la app armada sobre fakes.
