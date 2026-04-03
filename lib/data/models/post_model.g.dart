// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostModelAdapter extends TypeAdapter<PostModel> {
  @override
  final int typeId = 1;

  @override
  PostModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      type: fields[2] as String,
      petType: fields[3] as String,
      petName: fields[4] as String?,
      breed: fields[5] as String?,
      color: fields[6] as String?,
      description: fields[7] as String,
      lostDate: fields[8] as DateTime,
      latitude: fields[9] as double,
      longitude: fields[10] as double,
      locationName: fields[11] as String,
      images: (fields[12] as List).cast<String>(),
      contactMethod: fields[13] as String,
      phoneNumber: fields[14] as String?,
      isAnonymous: fields[15] as bool,
      isActive: fields[16] as bool,
      isSynced: fields[17] as bool,
      createdAt: fields[18] as DateTime,
      updatedAt: fields[19] as DateTime,
      viewCount: fields[20] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PostModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.petType)
      ..writeByte(4)
      ..write(obj.petName)
      ..writeByte(5)
      ..write(obj.breed)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.lostDate)
      ..writeByte(9)
      ..write(obj.latitude)
      ..writeByte(10)
      ..write(obj.longitude)
      ..writeByte(11)
      ..write(obj.locationName)
      ..writeByte(12)
      ..write(obj.images)
      ..writeByte(13)
      ..write(obj.contactMethod)
      ..writeByte(14)
      ..write(obj.phoneNumber)
      ..writeByte(15)
      ..write(obj.isAnonymous)
      ..writeByte(16)
      ..write(obj.isActive)
      ..writeByte(17)
      ..write(obj.isSynced)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt)
      ..writeByte(20)
      ..write(obj.viewCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
