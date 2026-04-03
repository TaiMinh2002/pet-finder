import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/post_entity.dart';
import '../../repositories/i_post_repository.dart';

class GetPostsUseCase {
  final IPostRepository _repo;
  GetPostsUseCase(this._repo);

  Future<Either<Failure, List<PostEntity>>> call({
    PostType? filterType,
    PetType? filterPetType,
  }) =>
      _repo.getPosts(filterType: filterType, filterPetType: filterPetType);
}
