import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';

class HiveLocalDataSource {
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters (generated via build_runner)
    if (!Hive.isAdapterRegistered(AppConstants.typeIdUser)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.typeIdPost)) {
      Hive.registerAdapter(PostModelAdapter());
    }
    await Future.wait([
      Hive.openBox<UserModel>(AppConstants.boxUsers),
      Hive.openBox<PostModel>(AppConstants.boxPosts),
      Hive.openBox<PostModel>(AppConstants.boxPendingPosts),
      Hive.openBox(AppConstants.boxSettings),
    ]);
  }

  // ── User ─────────────────────────────────────────────────────────────────
  Box<UserModel> get _usersBox => Hive.box<UserModel>(AppConstants.boxUsers);

  Future<void> saveUser(UserModel user) => _usersBox.put(user.uid, user);
  UserModel? getUser(String uid) => _usersBox.get(uid);
  Future<void> deleteUser(String uid) => _usersBox.delete(uid);

  // ── Posts ─────────────────────────────────────────────────────────────────
  Box<PostModel> get _postsBox => Hive.box<PostModel>(AppConstants.boxPosts);
  Box<PostModel> get _pendingBox => Hive.box<PostModel>(AppConstants.boxPendingPosts);

  Future<void> savePosts(List<PostModel> posts) async {
    final map = {for (final p in posts) p.id: p};
    await _postsBox.putAll(map);
  }

  Future<void> savePost(PostModel post) => _postsBox.put(post.id, post);

  List<PostModel> getAllPosts() => _postsBox.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  PostModel? getPost(String id) => _postsBox.get(id);

  Future<void> deletePost(String id) => _postsBox.delete(id);

  // Pending (offline queue)
  Future<void> addPending(PostModel post) => _pendingBox.put(post.id, post);
  List<PostModel> getPending() => _pendingBox.values.toList();
  Future<void> removePending(String id) => _pendingBox.delete(id);

  // ── Settings ─────────────────────────────────────────────────────────────
  Box get _settingsBox => Hive.box(AppConstants.boxSettings);

  T? getSetting<T>(String key) => _settingsBox.get(key) as T?;
  Future<void> saveSetting(String key, dynamic value) =>
      _settingsBox.put(key, value);
}
