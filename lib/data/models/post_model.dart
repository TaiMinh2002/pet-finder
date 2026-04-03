import 'package:hive/hive.dart';
import '../../domain/entities/post_entity.dart';

part 'post_model.g.dart';

@HiveType(typeId: 1)
class PostModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String type; // PostType name

  @HiveField(3)
  final String petType; // PetType name

  @HiveField(4)
  final String? petName;

  @HiveField(5)
  final String? breed;

  @HiveField(6)
  final String? color;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final DateTime lostDate;

  @HiveField(9)
  final double latitude;

  @HiveField(10)
  final double longitude;

  @HiveField(11)
  final String locationName;

  @HiveField(12)
  final List<String> images;

  @HiveField(13)
  final String contactMethod;

  @HiveField(14)
  final String? phoneNumber;

  @HiveField(15)
  final bool isAnonymous;

  @HiveField(16)
  final bool isActive;

  @HiveField(17)
  final bool isSynced;

  @HiveField(18)
  final DateTime createdAt;

  @HiveField(19)
  final DateTime updatedAt;

  @HiveField(20)
  final int viewCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.petType,
    this.petName,
    this.breed,
    this.color,
    required this.description,
    required this.lostDate,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.images,
    required this.contactMethod,
    this.phoneNumber,
    this.isAnonymous = false,
    this.isActive = true,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
  });

  factory PostModel.fromEntity(PostEntity e) => PostModel(
        id: e.id,
        userId: e.userId,
        type: e.type.name,
        petType: e.petType.name,
        petName: e.petName,
        breed: e.breed,
        color: e.color,
        description: e.description,
        lostDate: e.lostDate,
        latitude: e.latitude,
        longitude: e.longitude,
        locationName: e.locationName,
        images: e.images,
        contactMethod: e.contactMethod.name,
        phoneNumber: e.phoneNumber,
        isAnonymous: e.isAnonymous,
        isActive: e.isActive,
        isSynced: e.isSynced,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        viewCount: e.viewCount,
      );

  factory PostModel.fromMap(Map<String, dynamic> map) => PostModel(
        id: map['id'] as String,
        userId: map['userId'] as String,
        type: map['type'] as String,
        petType: map['petType'] as String,
        petName: map['petName'] as String?,
        breed: map['breed'] as String?,
        color: map['color'] as String?,
        description: map['description'] as String,
        lostDate: DateTime.fromMillisecondsSinceEpoch(map['lostDate'] as int),
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        locationName: map['locationName'] as String? ?? '',
        images: List<String>.from(map['images'] as List? ?? []),
        contactMethod: map['contactMethod'] as String? ?? 'phone',
        phoneNumber: map['phoneNumber'] as String?,
        isAnonymous: map['isAnonymous'] as bool? ?? false,
        isActive: map['isActive'] as bool? ?? true,
        isSynced: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
        viewCount: map['viewCount'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'type': type,
        'petType': petType,
        'petName': petName,
        'breed': breed,
        'color': color,
        'description': description,
        'lostDate': lostDate.millisecondsSinceEpoch,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'images': images,
        'contactMethod': contactMethod,
        'phoneNumber': phoneNumber,
        'isAnonymous': isAnonymous,
        'isActive': isActive,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'viewCount': viewCount,
      };

  PostEntity toEntity() => PostEntity(
        id: id,
        userId: userId,
        type: PostType.values.firstWhere((e) => e.name == type),
        petType: PetType.values.firstWhere((e) => e.name == petType),
        petName: petName,
        breed: breed,
        color: color,
        description: description,
        lostDate: lostDate,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        images: images,
        contactMethod: ContactMethod.values.firstWhere((e) => e.name == contactMethod),
        phoneNumber: phoneNumber,
        isAnonymous: isAnonymous,
        isActive: isActive,
        isSynced: isSynced,
        createdAt: createdAt,
        updatedAt: updatedAt,
        viewCount: viewCount,
      );
}
