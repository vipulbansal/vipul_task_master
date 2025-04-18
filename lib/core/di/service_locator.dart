import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vipul_task_master/domain/usecases/task_usecases.dart';
import 'package:vipul_task_master/presentation/blocs/task/tasks_bloc.dart';
import 'package:vipul_task_master/presentation/blocs/themecubit/theme_cubit.dart';

import '../../data/datasources/local/hive_service.dart';
import '../../data/datasources/remote/firestore_service.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../constants/hive_constants.dart';
import '../services/device_info_service.dart';
import '../services/notification_service.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {

  // Register services
  await registerServices();

  // Register repositories
  _registerRepositories();

  // Register use cases
  _registerUseCases();

  // Register BLoCs
  _registerBlocs();
}

registerServices()async{
  // Device Info Service
  sl.registerSingleton<DeviceInfoService>(DeviceInfoService());
  await sl<DeviceInfoService>().initialize();

  // Notification Service
  sl.registerSingleton<NotificationService>(NotificationService());
  await sl<NotificationService>().initialize();
  await sl<NotificationService>().requestPermissions();

  // Hive Service (local storage)
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TaskPriorityModelAdapter()); // Auto-generated adapter

  // Open boxes
  await Hive.openBox<TaskModel>(HiveConstants.taskBox);
  await Hive.openBox(HiveConstants.settingsBox);

  sl.registerSingleton<HiveService>(HiveService());

  // Firestore Service (remote storage)
  sl.registerSingleton<FirestoreService>(
    FirestoreService(sl<DeviceInfoService>()),
  );
}

/// Register repositories
void _registerRepositories() {
  sl.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(
      sl<HiveService>(),
      sl<FirestoreService>(),
    ),
  );
}


/// Register use cases
void _registerUseCases() {
  // Register task use cases
  sl.registerFactory(() => GetTasksUseCase(sl<TaskRepository>()));
  sl.registerFactory(() => GetTaskUseCase(sl<TaskRepository>()));
  sl.registerFactory(() => CreateTaskUseCase(sl<TaskRepository>()));
  sl.registerFactory(() => UpdateTaskUseCase(sl<TaskRepository>()));
  sl.registerFactory(() => DeleteTaskUseCase(sl<TaskRepository>()));
  sl.registerFactory(() => ToggleTaskCompletionUseCase(sl<TaskRepository>()));
  sl.registerFactory(() => SyncTasksUseCase(sl<TaskRepository>()));
}


/// Register BLoCs
void _registerBlocs() {
  // Register TaskBloc
  sl.registerFactory(() => TaskBloc(
    getTasksUseCase: sl<GetTasksUseCase>(),
    getTaskUseCase: sl<GetTaskUseCase>(),
    createTaskUseCase: sl<CreateTaskUseCase>(),
    updateTaskUseCase: sl<UpdateTaskUseCase>(),
    deleteTaskUseCase: sl<DeleteTaskUseCase>(),
    notificationService: sl<NotificationService>(),
    syncTasksUseCase: sl<SyncTasksUseCase>()
  ));

  // Register ThemeCubit
  sl.registerFactory(() => ThemeCubit());
}
