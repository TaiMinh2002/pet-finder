import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/post_entity.dart';

abstract class IPostRepository {
  Future<Either<Failure, List<PostEntity>>> getPosts({
    PostType? filterType,
    PetType? filterPetType,
  });

  Future<Either<Failure, PostEntity>> getPostById(String postId);

  Future<Either<Failure, PostEntity>> createPost(PostEntity post);

  Future<Either<Failure, PostEntity>> updatePost(PostEntity post);

  Future<Either<Failure, void>> deletePost(String postId);

  Future<Either<Failure, List<String>>> uploadImages(List<String> localPaths);

  Future<Either<Failure, void>> syncPendingPosts();

  Stream<List<PostEntity>> getPostsStream({PostType? filterType});

  Future<Either<Failure, List<PostEntity>>> getPostsByUser(String userId);
}
