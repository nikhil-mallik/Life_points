// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityAdapter extends TypeAdapter<Activity> {
  @override
  final int typeId = 1;

  @override
  Activity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Activity(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      points: fields[3] as int,
      type: fields[4] as ActivityType,
      isCompleted: fields[5] as bool,
      completedAt: fields[6] as DateTime?,
      createdAt: fields[7] as DateTime,
      category: fields[8] as String,
      isChainable: fields[9] as bool,
      chainBonus: fields[10] as int,
      progressiveValues: (fields[11] as Map).cast<String, dynamic>(),
      progressiveWeek: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Activity obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.points)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.isChainable)
      ..writeByte(10)
      ..write(obj.chainBonus)
      ..writeByte(11)
      ..write(obj.progressiveValues)
      ..writeByte(12)
      ..write(obj.progressiveWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final int typeId = 2;

  @override
  ActivityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityType.earn;
      case 1:
        return ActivityType.spend;
      case 2:
        return ActivityType.positive;
      case 3:
        return ActivityType.negative;
      case 4:
        return ActivityType.daily;
      case 5:
        return ActivityType.weekly;
      case 6:
        return ActivityType.custom;
      default:
        return ActivityType.earn;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    switch (obj) {
      case ActivityType.earn:
        writer.writeByte(0);
        break;
      case ActivityType.spend:
        writer.writeByte(1);
        break;
      case ActivityType.positive:
        writer.writeByte(2);
        break;
      case ActivityType.negative:
        writer.writeByte(3);
        break;
      case ActivityType.daily:
        writer.writeByte(4);
        break;
      case ActivityType.weekly:
        writer.writeByte(5);
        break;
      case ActivityType.custom:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
