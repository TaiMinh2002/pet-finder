import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/i_post_repository.dart';
import '../../../domain/usecases/post/create_post_usecase.dart';
import '../../../domain/usecases/post/get_posts_usecase.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPosts;
  final CreatePostUseCase createPost;
  final IPostRepository postRepo;

  // Cache all unfiltered posts for tab counts
  List<dynamic> _cachedAllPosts = [];

  PostBloc({
    required this.getPosts,
    required this.createPost,
    required this.postRepo,
  }) : super(const PostInitial()) {
    on<PostsLoadRequested>(_onLoad);
    on<PostFilterChanged>(_onFilterChanged);
    on<PostCreateRequested>(_onCreate);
    on<PostImagesUploadRequested>(_onUploadImages);
    on<PostSyncRequested>(_onSync);
  }

  Future<void> _onLoad(
    PostsLoadRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());
    final result = await getPosts(
      filterType: event.filterType,
      filterPetType: event.filterPetType,
    );
    result.fold(
      (failure) => emit(PostError(failure.message)),
      (posts) {
        // Only update the unfiltered cache when loading without a filter
        if (event.filterType == null && event.filterPetType == null) {
          _cachedAllPosts = posts;
        }
        emit(PostsLoaded(
          posts: posts,
          allPosts: List.from(_cachedAllPosts),
          activeFilter: event.filterType,
          activePetFilter: event.filterPetType,
        ));
      },
    );
  }

  Future<void> _onFilterChanged(
    PostFilterChanged event,
    Emitter<PostState> emit,
  ) async {
    add(PostsLoadRequested(
      filterType: event.filterType,
      filterPetType: event.filterPetType,
    ));
  }

  Future<void> _onCreate(
    PostCreateRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostCreating());
    final result = await createPost(event.post);
    result.fold(
      (failure) => emit(PostError(failure.message)),
      (post) => emit(PostCreated(post)),
    );
  }

  Future<void> _onUploadImages(
    PostImagesUploadRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostImagesUploading());
    final result = await postRepo.uploadImages(event.filePaths);
    result.fold(
      (failure) => emit(PostError(failure.message)),
      (urls) => emit(PostImagesUploaded(urls)),
    );
  }

  Future<void> _onSync(
    PostSyncRequested event,
    Emitter<PostState> emit,
  ) async {
    await postRepo.syncPendingPosts();
  }
}
