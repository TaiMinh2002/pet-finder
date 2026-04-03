import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? avatarUrl;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromEntity(UserEntity e) => UserModel(
        uid: e.uid,
        name: e.name,
        email: e.email,
        phoneNumber: e.phoneNumber,
        avatarUrl: e.avatarUrl,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] as String,
        name: map['name'] as String?,
        email: map['email'] as String?,
        phoneNumber: map['phoneNumber'] as String?,
        avatarUrl: map['avatarUrl'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        updatedAt: map['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
      };

  UserEntity toEntity() => UserEntity(
        uid: uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
