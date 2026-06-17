import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hr_app/data/response/api_response.dart';
import 'package:hr_app/repository/auth_api/auth_api_repository.dart';
import 'package:hr_app/services/session_manager/session_controller.dart';
part 'login_events.dart';
part 'login_states.dart';

class LoginBloc extends Bloc<LoginEvents, LoginStates> {
  AuthApiRepository authApiRepository;

  LoginBloc({required this.authApiRepository}) : super(const LoginStates()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginApi>(_onFormSubmitted);
  }

  void _onEmailChanged(EmailChanged event, Emitter<LoginStates> emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginStates> emit) {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _onFormSubmitted(
    LoginApi event,
    Emitter<LoginStates> emit,
  ) async {
    final Map<String, String> data = {
      'email': state.email,
      'password': state.password,
    };
    emit(state.copyWith(loginApi: const ApiResponse.loading()));

    try {
      final value = await authApiRepository.loginApi(data);
      if (value.error.isNotEmpty) {
        emit(state.copyWith(loginApi: ApiResponse.error(value.error)));
        return;
      }
      await SessionController().saveUserInPreference(value);
      await SessionController().getUserFromPreference();
      emit(state.copyWith(loginApi: const ApiResponse.completed('LOGIN')));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Login failed: $e');
        debugPrintStack(stackTrace: st);
      }
      emit(state.copyWith(loginApi: ApiResponse.error(e.toString())));
    }
  }
}
