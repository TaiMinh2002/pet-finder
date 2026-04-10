import 'package:equatable/equatable.dart';

enum PostType { lost, found, resolved }

enum PetType { dog, cat, other }

enum ContactMethod { phone, zalo, both }

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final PostType type;
  final PetType petType;
  final String? petName;
  final String? breed;
  final String? color;
  final String description;
  final DateTime lostDate;
  final double latitude;
  final double longitude;
  final String locationName;
  final List<String> images;
  final ContactMethod contactMethod;
  final String? phoneNumber;
  final bool isAnonymous;
  final bool isActive;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;

  const PostEntity({
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

  bool get isLost => type == PostType.lost;
  bool get isFound => type == PostType.found;
  bool get isResolved => type == PostType.resolved;
  bool get hasImages => images.isNotEmpty;
  String? get thumbnailUrl => images.isNotEmpty ? images.first : null;

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        petType,
        createdAt,
        isActive,
        viewCount,
        description,
        images,
        updatedAt,
      ];
}
