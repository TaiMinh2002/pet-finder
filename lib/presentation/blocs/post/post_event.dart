import 'package:equatable/equatable.dart';
import '../../../domain/entities/post_entity.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();
  @override
  List<Object?> get props => [];
}

class PostsLoadRequested extends PostEvent {
  final PostType? filterType;
  final PetType? filterPetType;
  const PostsLoadRequested({this.filterType, this.filterPetType});
  @override
  List<Object?> get props => [filterType, filterPetType];
}

class PostCreateRequested extends PostEvent {
  final PostEntity post;
  const PostCreateRequested(this.post);
  @override
  List<Object> get props => [post];
}

class PostFilterChanged extends PostEvent {
  final PostType? filterType;
  final PetType? filterPetType;
  const PostFilterChanged({this.filterType, this.filterPetType});
  @override
  List<Object?> get props => [filterType, filterPetType];
}

class PostImagesUploadRequested extends PostEvent {
  final List<String> filePaths;
  const PostImagesUploadRequested(this.filePaths);
  @override
  List<Object> get props => [filePaths];
}

class PostSyncRequested extends PostEvent {
  const PostSyncRequested();
}
