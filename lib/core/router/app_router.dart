import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vipul_task_master/presentation/screens/add_edit_task_screen.dart';

import '../../domain/entities/task.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/task_detail_screen.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      // Home screen
      GoRoute(
        path: AppConstants.homeRoute,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.addTaskRoute,
        builder: (context, state) {
          return const AddEditTaskScreen();
        },
      ),
      GoRoute(
        path: AppConstants.editTaskRoute,
        builder: (context, state) {
          final task = state.extra as Task;
          return AddEditTaskScreen(task: task);
        },
      ),
      // Task detail screen
      GoRoute(
        path: '${AppConstants.taskDetailRoute}/:id',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          final task = state.extra as Task?;
          return TaskDetailScreen(taskId: taskId, task: task);
        },
      ),
    ],

    // Error screen
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Page Not Found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('The page ${state.uri.path} could not be found.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go(AppConstants.homeRoute);
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
