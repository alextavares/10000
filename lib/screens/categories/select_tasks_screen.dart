import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/task.dart';

class SelectTasksScreen extends StatefulWidget {
  final List<String> selectedTaskIds;
  final String? currentCategoryId;

  const SelectTasksScreen({
    super.key,
    required this.selectedTaskIds,
    this.currentCategoryId,
  });

  @override
  State<SelectTasksScreen> createState() => _SelectTasksScreenState();
}

class _SelectTasksScreenState extends State<SelectTasksScreen> {
  late List<String> _selectedTaskIds;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _selectedTaskIds = List.from(widget.selectedTaskIds);
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121212);
    const Color cardColor = Color(0xFF1E1E1E);
    const Color primaryTextColor = Colors.white;
    final Color secondaryTextColor = Colors.grey[500]!;
    const Color accentColor = Color(0xFFE91E63);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Selecionar Tarefas',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedTaskIds);
            },
            child: const Text(
              'CONCLUIR',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('tasks')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accentColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar tarefas',
                style: TextStyle(color: secondaryTextColor),
              ),
            );
          }

          final tasks = snapshot.data?.docs ?? [];

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma tarefa encontrada',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final taskData = tasks[index].data() as Map<String, dynamic>;
              final task = Task.fromMap({...taskData, 'id': tasks[index].id});
              final isSelected = _selectedTaskIds.contains(task.id);

              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: accentColor, width: 2)
                      : null,
                ),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTaskIds.remove(task.id);
                      } else {
                        _selectedTaskIds.add(task.id);
                      }
                    });
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.task_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    task.title,
                    style: const TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: task.description != null
                      ? Text(
                          task.description!,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: task.category == widget.currentCategoryId
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Atual',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
