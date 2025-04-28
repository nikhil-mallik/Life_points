// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLogAdapter extends TypeAdapter<ActivityLog> {
  @override
  final int typeId = 4;

  @override
  ActivityLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLog(
      id: fields[0] as String,
      activityId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      points: fields[3] as int,
      isChainCompleted: fields[4] as bool,
      chainBonus: fields[5] as int,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.activityId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.points)
      ..writeByte(4)
      ..write(obj.isChainCompleted)
      ..writeByte(5)
      ..write(obj.chainBonus)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityLogV2Adapter extends TypeAdapter<ActivityLogV2> {
  @override
  final int typeId = 2;

  @override
  ActivityLogV2 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLogV2(
      id: fields[0] as String?,
      activityId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      points: fields[3] as int,
      isChainCompleted: fields[4] as bool,
      chainBonus: fields[5] as int,
      notes: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLogV2 obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.activityId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.points)
      ..writeByte(4)
      ..write(obj.isChainCompleted)
      ..writeByte(5)
      ..write(obj.chainBonus)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogV2Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
