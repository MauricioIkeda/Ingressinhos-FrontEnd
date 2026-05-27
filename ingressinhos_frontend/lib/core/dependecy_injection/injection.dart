import 'package:get_it/get_it.dart';
import 'package:ingressinhos_frontend/core/network/clients/auth_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/events_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/events_remote_datasource_impl.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/issued_tickets_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/issued_tickets_remote_datasource_impl.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/cart_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/cart_remote_datasource_impl.dart';
import 'package:ingressinhos_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ingressinhos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/home/data/repositories/cart_repository_impl.dart';
import 'package:ingressinhos_frontend/features/home/data/repositories/events_repository_impl.dart';
import 'package:ingressinhos_frontend/features/home/data/repositories/issued_tickets_repository_impl.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/cart_repository.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/events_repository.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/issued_tickets_repository.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/cart_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/issued_tickets_cubit.dart';

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

  getIt.registerLazySingleton<EventsRemoteDatasource>(
    () => EventsRemoteDatasourceImpl(getIt<IngressinhosDioClient>()),
  );

  getIt.registerLazySingleton<IssuedTicketsRemoteDatasource>(
    () => IssuedTicketsRemoteDatasourceImpl(getIt<IngressinhosDioClient>()),
  );

  getIt.registerLazySingleton<CartRemoteDatasource>(
    () => CartRemoteDatasourceImpl(getIt<IngressinhosDioClient>()),
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
    () =>
        EventsRepositoryImpl(remoteDatasource: getIt<EventsRemoteDatasource>()),
  );

  getIt.registerLazySingleton<IssuedTicketsRepository>(
    () => IssuedTicketsRepositoryImpl(
      remoteDatasource: getIt<IssuedTicketsRemoteDatasource>(),
    ),
  );

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDatasource: getIt<CartRemoteDatasource>()),
  );

  getIt.registerFactory(
    () => EventsCubit(
      eventRepository: getIt<EventsRepository>()
    ),
  );

  getIt.registerFactory(
    () => IssuedTicketsCubit(
      issuedTicketsRepository: getIt<IssuedTicketsRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => CartCubit(cartRepository: getIt<CartRepository>()),
  );
}
