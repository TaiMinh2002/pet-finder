import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remote;
  final HiveLocalDataSource _local;
  final ConnectivityService _connectivity;

  AuthRepositoryImpl(this._remote, this._local, this._connectivity);

  @override
  Stream<UserEntity?> get authStateChanges =>
      _remote.authStateChanges.map((m) => m?.toEntity());

  @override
  UserEntity? get currentUser => _remote.currentUser?.toEntity();

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!await _connectivity.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model =
          await _remote.signInWithEmail(email: email, password: password);
      await _local.saveUser(model);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!await _connectivity.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = await _remote.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      await _local.saveUser(model);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) async {
    if (!await _connectivity.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      await _remote.sendPasswordReset(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }
}
