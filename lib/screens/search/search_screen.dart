import 'package:flutter/material.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/recurring_task.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/widgets/task_card.dart';
import 'package:myapp/widgets/habit_card.dart';
import 'package:myapp/widgets/recurring_task_card.dart';

enum SearchItemType { task, habit, recurringTask }

class SearchItem {
  final dynamic item;
  final SearchItemType type;
  final String searchableText;

  SearchItem({
    required this.item,
    required this.type,
    required this.searchableText,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchItem> _allItems = [];
  List<SearchItem> _filteredItems = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';

  final List<String> _filterOptions = ['Todos', 'Tarefas', 'Hábitos', 'Tarefas Recorrentes'];

  @override
  void initState() {
    super.initState();
    _loadAllItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllItems() async {
    setState(() => _isLoading = true);

    try {
      final taskService = ServiceProvider.of(context).taskService;
      final habitService = ServiceProvider.of(context).habitService;
      final recurringTaskService = ServiceProvider.of(context).recurringTaskService;

      final tasks = await taskService.getTasks();
      final habits = await habitService.getHabits();
      final recurringTasks = await recurringTaskService.getRecurringTasks();

      List<SearchItem> items = [];

      // Add tasks
      for (var task in tasks) {
        items.add(SearchItem(
          item: task,
          type: SearchItemType.task,
          searchableText: '${task.title} ${task.description ?? ''} ${task.category ?? ''}'.toLowerCase(),
        ));
      }

      // Add habits
      for (var habit in habits) {
        items.add(SearchItem(
          item: habit,
          type: SearchItemType.habit,
          searchableText: '${habit.title} ${habit.description ?? ''} ${habit.category ?? ''}'.toLowerCase(),
        ));
      }

      // Add recurring tasks
      for (var recurringTask in recurringTasks) {
        items.add(SearchItem(
          item: recurringTask,
          type: SearchItemType.recurringTask,
          searchableText: '${recurringTask.title} ${recurringTask.description ?? ''} ${recurringTask.category ?? ''}'.toLowerCase(),
        ));
      }

      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar itens: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    _filterItems();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredItems = _allItems.where((item) {
        // Filter by type
        bool matchesType = true;
        if (_selectedFilter != 'Todos') {
          switch (_selectedFilter) {
            case 'Tarefas':
              matchesType = item.type == SearchItemType.task;
              break;
            case 'Hábitos':
              matchesType = item.type == SearchItemType.habit;
              break;
            case 'Tarefas Recorrentes':
              matchesType = item.type == SearchItemType.recurringTask;
              break;
          }
        }

        // Filter by search query
        bool matchesQuery = query.isEmpty || item.searchableText.contains(query);

        return matchesType && matchesQuery;
      }).toList();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterItems();
  }

  Widget _buildSearchItem(SearchItem searchItem) {
    switch (searchItem.type) {
      case SearchItemType.task:
        final task = searchItem.item as Task;
        return TaskCard(
          task: task,
          onToggleCompletion: (taskId, completed) async {
            await ServiceProvider.of(context).taskService.markTaskCompletion(taskId, DateTime.now(), completed);
            _loadAllItems(); // Refresh the list
          },
          onEdit: () {
            // Navigate to edit task screen
            Navigator.of(context).pop(); // Close search screen
          },
          onDelete: () async {
            final success = await ServiceProvider.of(context).taskService.deleteTask(task.id);
            if (success) {
              _loadAllItems(); // Refresh the list
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarefa excluída com sucesso')),
                );
              }
            }
          },
        );

      case SearchItemType.habit:
        final habit = searchItem.item as Habit;
        return HabitCard(
          habit: habit,
          onTap: () {
            // Handle habit tap
          },
          onToggleCompletion: (completed) async {
            await ServiceProvider.of(context).habitService.markHabitCompletion(habit.id, DateTime.now(), completed);
            _loadAllItems(); // Refresh the list
          },
          onDelete: () async {
            await ServiceProvider.of(context).habitService.deleteHabit(habit.id);
            _loadAllItems(); // Refresh the list
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hábito excluído com sucesso')),
              );
            }
          },
        );

      case SearchItemType.recurringTask:
        final recurringTask = searchItem.item as RecurringTask;
        return RecurringTaskCard(
          recurringTask: recurringTask,
          onToggleCompletion: (recurringTaskId, completed) async {
            await ServiceProvider.of(context).recurringTaskService.markRecurringTaskCompletion(recurringTaskId, DateTime.now(), completed);
            _loadAllItems(); // Refresh the list
          },
          onEdit: () {
            // Navigate to edit recurring task screen
            Navigator.of(context).pop(); // Close search screen
          },
          onDelete: () async {
            final success = await ServiceProvider.of(context).recurringTaskService.deleteRecurringTask(recurringTask.id);
            if (success) {
              _loadAllItems(); // Refresh the list
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarefa recorrente excluída com sucesso')),
                );
              }
            }
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'Buscar tarefas, hábitos...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) => _onFilterChanged(filter),
                    backgroundColor: Colors.grey[800],
                    selectedColor: const Color(0xFFE91E63),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    checkmarkColor: Colors.white,
                  ),
                );
              },
            ),
          ),
          // Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                    ),
                  )
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isEmpty ? Icons.search : Icons.search_off,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Digite algo para buscar'
                                  : 'Nenhum resultado encontrado',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                            if (_searchController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Tente usar palavras-chave diferentes',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildSearchItem(_filteredItems[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
