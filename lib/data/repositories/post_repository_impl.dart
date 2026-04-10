import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/i_post_repository.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../datasources/remote/cloudinary_datasource.dart';
import '../datasources/remote/post_remote_datasource.dart';
import '../models/post_model.dart';
import '../models/post_model_ext.dart';

class PostRepositoryImpl implements IPostRepository {
  final PostRemoteDataSource _remote;
  final HiveLocalDataSource _local;
  final CloudinaryDataSource _cloudinary;
  final ConnectivityService _connectivity;

  PostRepositoryImpl(
    this._remote,
    this._local,
    this._cloudinary,
    this._connectivity,
  );

  @override
  Stream<List<PostEntity>> getPostsStream({PostType? filterType}) => _remote
      .getPostsStream(filterType: filterType?.name)
      .map((posts) => posts.map((p) => p.toEntity()).toList());

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts({
    PostType? filterType,
    PetType? filterPetType,
  }) async {
    if (await _connectivity.isConnected) {
      try {
        final models = await _remote.getPosts();
        await _local.savePosts(models);
        final entities = models
            .where((p) => filterType == null || p.type == filterType.name)
            .where(
                (p) => filterPetType == null || p.petType == filterPetType.name)
            .map((p) => p.toEntity())
            .toList();
        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      // Offline — serve from Hive cache
      final cached = _local
          .getAllPosts()
          .where((p) => filterType == null || p.type == filterType.name)
          .where(
              (p) => filterPetType == null || p.petType == filterPetType.name)
          .map((p) => p.toEntity())
          .toList();
      return Right(cached);
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async {
    try {
      final model = await _remote.getPostById(postId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      final cached = _local.getPost(postId);
      if (cached != null) return Right(cached.toEntity());
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost(PostEntity post) async {
    final model = PostModel.fromEntity(post);
    if (await _connectivity.isConnected) {
      try {
        await _remote.createPost(model);
        await _local.savePost(model.copyWith(isSynced: true));
        return Right(post);
      } on ServerException catch (e) {
        await _local.addPending(model);
        return Left(ServerFailure(e.message));
      }
    } else {
      await _local.savePost(model);
      await _local.addPending(model);
      return Right(post);
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost(PostEntity post) async {
    try {
      final model = PostModel.fromEntity(post);
      await _remote.updatePost(model);
      await _local.savePost(model.copyWith(isSynced: true));
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await _remote.deletePost(postId);
      await _local.deletePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadImages(
      List<String> localPaths) async {
    try {
      final urls = await _cloudinary.uploadImages(localPaths);
      return Right(urls);
    } on UploadException catch (e) {
      return Left(UploadFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingPosts() async {
    if (!await _connectivity.isConnected) return const Right(null);
    final pending = _local.getPending();
    for (final post in pending) {
      try {
        await _remote.createPost(post);
        await _local.savePost(post.copyWith(isSynced: true));
        await _local.removePending(post.id);
      } catch (_) {
        // Keep in pending queue, retry next time
      }
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getPostsByUser(
      String userId) async {
    try {
      final models = await _remote.getPostsByUser(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
