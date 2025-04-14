import 'package:get_it/get_it.dart';
import 'package:vipul_task_master/presentation/blocs/themecubit/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {

  await registerBlocs();
}

registerBlocs() {
  sl.registerFactory(() => ThemeCubit());
}
