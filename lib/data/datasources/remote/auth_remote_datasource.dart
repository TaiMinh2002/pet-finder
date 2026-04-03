import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  AuthRemoteDataSource(this._auth);

  Stream<UserModel?> get authStateChanges => _auth.authStateChanges().map(
        (user) => user == null ? null : _firebaseUserToModel(user),
      );

  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _firebaseUserToModel(user);
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _firebaseUserToModel(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed');
    }
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();
      return _firebaseUserToModel(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign up failed');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send reset email');
    }
  }

  UserModel _firebaseUserToModel(User user) => UserModel(
        uid: user.uid,
        name: user.displayName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        avatarUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
}
