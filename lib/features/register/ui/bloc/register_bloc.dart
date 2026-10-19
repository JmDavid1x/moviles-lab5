import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_event.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_state.dart';

/// Hace UNA sola llamada al caso de uso; no sabe que por dentro son dos pasos.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._signUp) : super(const RegisterState()) {
    on<RegisterSubmitted>(_alEnviar);
  }

  final SignUpUseCase _signUp;

  static const _errorGenerico = 'Algo salió mal. Intenta de nuevo.';

  Future<void> _alEnviar(
    RegisterSubmitted evento,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      final perfil = await _signUp(
        username: evento.username,
        fullName: evento.fullName,
        email: evento.email,
        password: evento.password,
      );
      emit(
        state.copyWith(
          status: RegisterStatus.success,
          profile: perfil,
          email: evento.email.trim(),
        ),
      );
    } on AuthFailure catch (falla) {
      emit(_fallo(falla.message));
    } catch (_) {
      emit(_fallo(_errorGenerico));
    }
  }

  RegisterState _fallo(String mensaje) =>
      state.copyWith(status: RegisterStatus.failure, errorMessage: mensaje);
}
