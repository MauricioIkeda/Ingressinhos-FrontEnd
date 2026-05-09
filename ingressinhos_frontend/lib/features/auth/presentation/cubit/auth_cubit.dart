import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/features/auth/data/models/register_user_model.dart';
import 'package:ingressinhos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> checkAuthentication() async {
    final logged = await authRepository.isLoggedIn();
    if (logged) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register({required RegisterUserModel registerUserModel}) async {
    emit(AuthLoading());

    try {
      await authRepository.register(
        name: registerUserModel.name,
        email: registerUserModel.email,
        password: registerUserModel.password,
        cpf: registerUserModel.cpf,
      );
      emit(AuthUnauthenticated());
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);

      emit(AuthUnauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      await authRepository.login(email: email, password: password);
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
