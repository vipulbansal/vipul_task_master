import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../blocs/task/tasks_bloc.dart';
import '../blocs/themecubit/theme_cubit.dart';
import '../widgets/task_item.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when screen is first shown
    context.read<TaskBloc>().add(const FetchTasksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // Theme toggle button
          IconButton(
            icon: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return Icon(
                  state.themeMode == ThemeMode.dark 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                );
              },
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
          // Sync button
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<TaskBloc>().add(const SyncTasksEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syncing tasks...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is NotificationPermissionDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: () {
                    // This would ideally open system settings
                    // For now just dismiss the snackbar
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is TasksLoaded) {
            final tasks = state.tasks;
            
            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.task_alt,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add a new task',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Group tasks by completion status
            final completedTasks = tasks.where((task) => task.isCompleted).toList();
            final pendingTasks = tasks.where((task) => !task.isCompleted).toList();
            
            // Sort pending tasks by due date
            pendingTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
            
            // Sort completed tasks by completion date (updated date)
            completedTasks.sort((a, b) => 
              (b.updatedAt ?? b.createdAt)
                  .compareTo(a.updatedAt ?? a.createdAt));
            
            return CustomScrollView(
              slivers: [
                // Pending tasks section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Pending Tasks (${pendingTasks.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < pendingTasks.length) {
                        return TaskItem(
                          task: pendingTasks[index],
                          onTap: (task) => _openTaskDetails(context, task),
                          onToggleCompletion: _toggleTaskCompletion,
                        );
                      }
                      return null;
                    },
                    childCount: pendingTasks.length,
                  ),
                ),
                
                // Completed tasks section (if any)
                if (completedTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Completed Tasks (${completedTasks.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < completedTasks.length) {
                          return TaskItem(
                            task: completedTasks[index],
                            onTap: (task) => _openTaskDetails(context, task),
                            onToggleCompletion: _toggleTaskCompletion,
                          );
                        }
                        return null;
                      },
                      childCount: completedTasks.length,
                    ),
                  ),
                ],
                
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          }
          
          return const Center(
            child: Text('Failed to load tasks'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _addTask(BuildContext context) {
    context.push(AppConstants.addTaskRoute);
  }
  
  void _openTaskDetails(BuildContext context, Task task) {
    context.push('${AppConstants.taskDetailRoute}/${task.id}', extra: task);
  }
  
  void _toggleTaskCompletion(String taskId, bool isCompleted) {
    context.read<TaskBloc>().add(ToggleTaskCompletionEvent(taskId, isCompleted));
  }
}