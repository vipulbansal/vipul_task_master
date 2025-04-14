import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vipul_task_master/presentation/blocs/themecubit/theme_cubit.dart';

import '../../data/models/task_model.dart';
import '../constants/hive_constants.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {

  await registerServices();
  await registerBlocs();
}

registerServices()async{
  // Hive Service (local storage)
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TaskPriorityModelAdapter());

  // Open boxes
  await Hive.openBox<TaskModel>(HiveConstants.taskBox);
  await Hive.openBox(HiveConstants.settingsBox);
}

registerBlocs() {
  sl.registerFactory(() => ThemeCubit());
}
