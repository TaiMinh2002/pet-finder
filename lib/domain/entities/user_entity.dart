import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  String get displayName => name ?? email?.split('@').first ?? 'User';

  @override
  List<Object?> get props => [uid, name, email, phoneNumber, avatarUrl];
}
