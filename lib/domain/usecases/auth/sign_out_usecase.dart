import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/i_auth_repository.dart';

class SignOutUseCase {
  final IAuthRepository _repo;
  SignOutUseCase(this._repo);

  Future<Either<Failure, void>> call() => _repo.signOut();
}
