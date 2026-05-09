import 'package:get_it/get_it.dart';
import 'package:ingressinhos_frontend/core/network/clients/auth_dio_client.dart';
import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:ingressinhos_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ingressinhos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<AuthDioClient>(()=> AuthDioClient());

  getIt.registerLazySingleton(() => SecureStorageService());

  getIt.registerLazySingleton<AuthRemoteDatasource>(() => AuthRemoteDatasourceImpl(getIt()));

  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDatasource: getIt(), storage: getIt()));

  getIt.registerFactory(() => AuthCubit(authRepository: getIt()));
}