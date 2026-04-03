import 'package:equatable/equatable.dart';
import '../../../domain/entities/post_entity.dart';

abstract class PostState extends Equatable {
  const PostState();
  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {
  const PostInitial();
}

class PostLoading extends PostState {
  const PostLoading();
}

class PostsLoaded extends PostState {
  final List<PostEntity> posts;
  final PostType? activeFilter;
  final PetType? activePetFilter;
  const PostsLoaded({
    required this.posts,
    this.activeFilter,
    this.activePetFilter,
  });
  @override
  List<Object?> get props => [posts, activeFilter, activePetFilter];
}

class PostCreating extends PostState {
  const PostCreating();
}

class PostCreated extends PostState {
  final PostEntity post;
  const PostCreated(this.post);
  @override
  List<Object> get props => [post];
}

class PostImagesUploading extends PostState {
  const PostImagesUploading();
}

class PostImagesUploaded extends PostState {
  final List<String> urls;
  const PostImagesUploaded(this.urls);
  @override
  List<Object> get props => [urls];
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);
  @override
  List<Object> get props => [message];
}
