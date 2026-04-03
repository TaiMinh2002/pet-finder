import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'core/network/connectivity_service.dart';
import 'data/datasources/local/hive_local_datasource.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/cloudinary_datasource.dart';
import 'data/datasources/remote/post_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/post_repository_impl.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_post_repository.dart';
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'domain/usecases/post/create_post_usecase.dart';
import 'domain/usecases/post/get_posts_usecase.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/post/post_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── External ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ── Core ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService.instance,
  );
  sl.registerLazySingleton<HiveLocalDataSource>(() => HiveLocalDataSource());

  // ── Data sources ──────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<CloudinaryDataSource>(
    () => CloudinaryDataSource(sl()),
  );

  // ── Repositories ──────────────────────────────────────────────────────
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<IPostRepository>(
    () => PostRepositoryImpl(sl(), sl(), sl(), sl()),
  );

  // ── Use cases ─────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));

  // ── BLoCs ─────────────────────────────────────────────────────────────
  sl.registerFactory(() => AuthBloc(
        signIn: sl(),
        signUp: sl(),
        signOut: sl(),
        authRepo: sl(),
      ));
  sl.registerFactory(() => PostBloc(
        getPosts: sl(),
        createPost: sl(),
        postRepo: sl(),
      ));
}
