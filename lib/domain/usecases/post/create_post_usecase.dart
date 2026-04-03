import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/post_entity.dart';
import '../../repositories/i_post_repository.dart';

class CreatePostUseCase {
  final IPostRepository _repo;
  CreatePostUseCase(this._repo);

  Future<Either<Failure, PostEntity>> call(PostEntity post) =>
      _repo.createPost(post);
}
