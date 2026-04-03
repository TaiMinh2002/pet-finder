import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/post_model.dart';

class PostRemoteDataSource {
  final FirebaseFirestore _db;
  PostRemoteDataSource(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.colPosts);

  Stream<List<PostModel>> getPostsStream() => _col
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => PostModel.fromMap({...d.data(), 'id': d.id}))
          .toList());

  Future<List<PostModel>> getPosts() async {
    try {
      final snap = await _col
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snap.docs
          .map((d) => PostModel.fromMap({...d.data(), 'id': d.id}))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch posts: $e');
    }
  }

  Future<PostModel> getPostById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) throw ServerException('Post not found');
      return PostModel.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw ServerException('Failed to get post: $e');
    }
  }

  Future<PostModel> createPost(PostModel post) async {
    try {
      final docRef = _col.doc(post.id);
      await docRef.set(post.toMap());
      return post;
    } catch (e) {
      throw ServerException('Failed to create post: $e');
    }
  }

  Future<PostModel> updatePost(PostModel post) async {
    try {
      await _col.doc(post.id).update(post.toMap());
      return post;
    } catch (e) {
      throw ServerException('Failed to update post: $e');
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await _col.doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete post: $e');
    }
  }

  Future<List<PostModel>> getPostsByUser(String userId) async {
    try {
      final snap = await _col
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((d) => PostModel.fromMap({...d.data(), 'id': d.id}))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get user posts: $e');
    }
  }
}
