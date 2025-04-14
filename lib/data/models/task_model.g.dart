// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      dueDate: fields[3] as DateTime,
      priority: fields[4] as TaskPriority,
      hasReminder: fields[5] as bool,
      isCompleted: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.hasReminder)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapterAdapter extends TypeAdapter<TaskPriorityAdapter> {
  @override
  final int typeId = 1;

  @override
  TaskPriorityAdapter read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriorityAdapter.low;
      case 1:
        return TaskPriorityAdapter.medium;
      case 2:
        return TaskPriorityAdapter.high;
      default:
        return TaskPriorityAdapter.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriorityAdapter obj) {
    switch (obj) {
      case TaskPriorityAdapter.low:
        writer.writeByte(0);
        break;
      case TaskPriorityAdapter.medium:
        writer.writeByte(1);
        break;
      case TaskPriorityAdapter.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
