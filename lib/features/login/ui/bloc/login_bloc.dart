import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_event.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_state.dart';

/// Mismo patrón que RegisterBloc, pero con SignInUseCase.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._signIn) : super(const LoginState()) {
    on<LoginSubmitted>(_alEnviar);
  }

  final SignInUseCase _signIn;

  static const _errorGenerico = 'Algo salió mal. Intenta de nuevo.';

  Future<void> _alEnviar(
    LoginSubmitted evento,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final (:profile, :email) = await _signIn(
        email: evento.email,
        password: evento.password,
      );
      emit(
        state.copyWith(
          status: LoginStatus.success,
          profile: profile,
          email: email,
        ),
      );
    } on AuthFailure catch (falla) {
      emit(_fallo(falla.message));
    } catch (_) {
      emit(_fallo(_errorGenerico));
    }
  }

  LoginState _fallo(String mensaje) =>
      state.copyWith(status: LoginStatus.failure, errorMessage: mensaje);
}
