import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/task.dart';
import '../blocs/task/tasks_bloc.dart';
import '../blocs/themecubit/theme_cubit.dart';
import '../widgets/task_item.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with RouteAware{
  @override
  void initState() {
    super.initState();
    // Load tasks when screen is first shown
    context.read<TaskBloc>().add(const FetchTasksEvent());
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    // this works but I am commenting this just to use then and proves that work too
    //context.read<TaskBloc>().add(const FetchTasksEvent());
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
          else if (state is TaskSync) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.syncStatus?"Synced Successfully":"Sync Failed"),
                backgroundColor: state.syncStatus?Colors.green:Colors.red,
              ),
            );
          }
        },
        buildWhen: (previous,current)=>current.runtimeType!=TaskSync,
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
          else if (state is TaskError) {
            return const Center(child: Text('Failed to load tasks'));
          }
          print('vipul state is ${state.runtimeType}');
          // Default: return an empty or loading placeholder (NOT error)
          return const SizedBox.shrink(); // Or a loader if you'd prefer
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _addTask(BuildContext context) {
    TaskBloc taskBloc=context.read<TaskBloc>();
    context.push(AppConstants.addTaskRoute).then((value)async{
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          taskBloc.add(const FetchTasksEvent());
        }
      });
    });
  }

  void _openTaskDetails(BuildContext context, Task task) {
    TaskBloc taskBloc=context.read<TaskBloc>();
    context.push('${AppConstants.taskDetailRoute}/${task.id}', extra: task).then((value) {
      // Wait for next frame when widget is fully ready again
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          taskBloc.add(const FetchTasksEvent());
        }
      });
    });
  }
  
  void _toggleTaskCompletion(String taskId, bool isCompleted) {
    context.read<TaskBloc>().add(ToggleTaskCompletionEvent(taskId, isCompleted));
  }
}