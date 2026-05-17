import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/features/auth/data/models/login_user_model.dart';
import 'package:ingressinhos_frontend/features/auth/data/models/register_user_client_model.dart';
import 'package:ingressinhos_frontend/features/auth/data/models/register_user_seller_model.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/auth_exception.dart';
import 'package:ingressinhos_frontend/features/auth/domain/enums/auth_type.dart';
import 'package:ingressinhos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> checkAuthentication() async {
    final logged = await authRepository.isLoggedIn();
    if (logged == AuthType.loggedIn) {
      emit(AuthAuthenticated());
    } else if (logged == AuthType.loggedInWithServerError) {
      emit(AuthServerDisconnected());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> registerClient({
    required RegisterUserClientModel registerUserModel,
  }) async {
    emit(AuthLoading());

    try {
      await authRepository.registerClient(
        name: registerUserModel.name,
        email: registerUserModel.email,
        password: registerUserModel.password,
        cpf: registerUserModel.cpf,
      );
      emit(AuthRegisterSuccess());
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> registerSeller({
    required RegisterUserSellerModel registerUserModel,
  }) async {
    emit(AuthLoading());

    try {
      await authRepository.registerSeller(
        name: registerUserModel.name,
        email: registerUserModel.email,
        password: registerUserModel.password,
        cnpj: registerUserModel.cnpj,
        tradingName: registerUserModel.tradingName,
      );
      emit(AuthRegisterSuccess());
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> login({required LoginUserModel loginUserModel}) async {
    emit(AuthLoading());

    try {
      await authRepository.login(
        email: loginUserModel.email,
        password: loginUserModel.password,
      );
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  String _mapError(Object error) {
    if (error is AuthException) {
      return error.message;
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> logout() async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
