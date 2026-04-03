import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

class SignInUseCase {
  final IAuthRepository _repo;
  SignInUseCase(this._repo);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) =>
      _repo.signInWithEmail(email: email, password: password);
}
