import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

class SignUpUseCase {
  final IAuthRepository _repo;
  SignUpUseCase(this._repo);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String name,
  }) =>
      _repo.signUpWithEmail(email: email, password: password, name: name);
}
