import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/repositories/i_post_repository.dart';
import '../../../domain/usecases/post/create_post_usecase.dart';
import '../../../domain/usecases/post/get_posts_usecase.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPosts;
  final CreatePostUseCase createPost;
  final IPostRepository postRepo;

  // Typed cache of all unfiltered posts for client-side tab filtering.
  List<PostEntity> _cachedAllPosts = [];

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
        // Populate the unfiltered cache whenever we load without a filter,
        // so subsequent _onFilterChanged calls don't need a network call.
        if (event.filterType == null && event.filterPetType == null) {
          _cachedAllPosts = List<PostEntity>.from(posts);
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
    // Apply filter against the in-memory cache — no Firestore round-trip.
    final filtered = _cachedAllPosts
        .where((p) => event.filterType == null || p.type == event.filterType)
        .where((p) =>
            event.filterPetType == null || p.petType == event.filterPetType)
        .toList();
    emit(PostsLoaded(
      posts: filtered,
      allPosts: List.from(_cachedAllPosts),
      activeFilter: event.filterType,
      activePetFilter: event.filterPetType,
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
