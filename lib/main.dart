import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vipul_task_master/core/di/service_locator.dart';
import 'package:vipul_task_master/core/router/app_router.dart';
import 'package:vipul_task_master/core/themes/app_theme.dart';
import 'package:vipul_task_master/presentation/blocs/themecubit/theme_cubit.dart';

main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  await initServiceLocator();
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const VipulTaskMaster());
}

class VipulTaskMaster extends StatelessWidget {
  const VipulTaskMaster({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_)=>sl<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Task Master',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            routerConfig: AppRouter.goRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}



