import 'package:get_it/get_it.dart';
import 'package:ingressinhos_frontend/core/network/clients/auth_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/ingressinhos_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/ingressinhos_remote_datasource_impl.dart';
import 'package:ingressinhos_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ingressinhos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/home/data/repositories/events_repository_impl.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/events_repository.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_cubit.dart';

final getIt = GetIt.instance;

void setup() {
  // Storage

  getIt.registerLazySingleton(() => SecureStorageService());

  // Network Clients

  getIt.registerLazySingleton<AuthDioClient>(() => AuthDioClient());

  getIt.registerLazySingleton<IngressinhosDioClient>(
    () => IngressinhosDioClient(getIt<SecureStorageService>()),
  );

  // Datasources

  getIt.registerLazySingleton<IngressinhosRemoteDatasource>(
    () => IngressinhosRemoteDatasourceImpl(getIt<IngressinhosDioClient>()),
  );

  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(
      getIt<AuthDioClient>(),
      getIt<IngressinhosDioClient>(),
    ),
  );

  // Repositories

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDatasource: getIt<AuthRemoteDatasource>(),
      storage: getIt<SecureStorageService>(),
    ),
  );

  getIt.registerFactory(
    () => AuthCubit(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<EventsRepository>(
    () => EventsRepositoryImpl(
      remoteDatasource: getIt<IngressinhosRemoteDatasource>(),
    ),
  );

  getIt.registerFactory(
    () => EventsCubit(repository: getIt<EventsRepository>()),
  );
}
