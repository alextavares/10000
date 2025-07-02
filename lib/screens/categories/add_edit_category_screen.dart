import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/habit_service.dart'; // Para reatribuição de hábitos ao excluir
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/utils/logger.dart';
import 'package:provider/provider.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? categoryToEdit;

  const AddEditCategoryScreen({
    super.key,
    this.categoryToEdit,
  });

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late Color _selectedColor;
  bool _isLoading = false;
  bool get _isEditing => widget.categoryToEdit != null;

  // Lista de ícones disponíveis
  final List<IconData> _availableIcons = [
    Icons.work_outline, Icons.school_outlined, Icons.favorite_border,
    Icons.fitness_center, Icons.lightbulb_outline, Icons.music_note,
    Icons.book, Icons.palette, Icons.attach_money, Icons.home_outlined,
    Icons.pets, Icons.spa, Icons.shopping_cart, Icons.flight, Icons.restaurant,
    Icons.directions_run, Icons.monitor_heart, Icons.eco, Icons.build, Icons.code,
    Icons.groups, Icons.self_improvement, Icons.psychology, Icons.menu_book,
    Icons.emoji_events, Icons.savings, Icons.public, Icons.park, Icons.star_border_purple500_outlined,
    Icons.dashboard_customize_outlined, Icons.apps_outlined, // Adicionando ícones mais genéricos
  ];


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryToEdit?.name ?? '');
    _selectedIcon = widget.categoryToEdit?.icon ?? _availableIcons.first;
    _selectedColor = widget.categoryToEdit?.color ?? AppTheme.primaryColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final categoryService = Provider.of<CategoryService>(context, listen: false);
    final String name = _nameController.text.trim();

    try {
      if (_isEditing) {
        final updatedCategory = widget.categoryToEdit!.copyWith(
          name: name,
          icon: _selectedIcon,
          color: _selectedColor,
          updatedAt: DateTime.now(),
        );
        await categoryService.updateCategory(updatedCategory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoria atualizada com sucesso!')),
          );
          Navigator.pop(context, true); // true indica que houve alteração
        }
      } else {
        // Criando nova categoria
        await categoryService.addCategory(
          name: name,
          icon: _selectedIcon,
          color: _selectedColor,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoria criada com sucesso!')),
          );
          Navigator.pop(context, true); // true indica que houve alteração
        }
      }
    } catch (e) {
      Logger.error('Error saving category: $e', e, StackTrace.current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar categoria: ${e.toString().replaceFirst("Exception: ", "")}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteCategory() async {
    if (!_isEditing || widget.categoryToEdit == null || widget.categoryToEdit!.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta categoria não pode ser excluída.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: const Text('Excluir Categoria', style: TextStyle(color: Colors.white)),
          content: Text(
            'Tem certeza que deseja excluir a categoria "${widget.categoryToEdit!.name}"? Os hábitos associados a esta categoria serão movidos para "Outros". Esta ação não pode ser desfeita.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7))),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
              child: const Text('Excluir'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final categoryService = Provider.of<CategoryService>(context, listen: false);
        final habitService = Provider.of<HabitService>(context, listen: false);
        await categoryService.deleteCategory(widget.categoryToEdit!.id, habitService: habitService);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Categoria "${widget.categoryToEdit!.name}" excluída com sucesso.')),
          );
          Navigator.of(context).pop(true); // Retorna true para indicar que a lista precisa ser atualizada
        }
      } catch (e) {
        Logger.error("Error deleting category: $e", e, StackTrace.current);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir categoria: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escolher Ícone',
                style: AppTheme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // Ajuste conforme necessário
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    final bool isSelected = _selectedIcon.codePoint == icon.codePoint;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedIcon = icon);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? _selectedColor.withOpacity(0.3) : AppTheme.surfaceColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? _selectedColor : Colors.grey[700]!,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(icon, color: isSelected ? _selectedColor : Colors.white70, size: 30),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker() {
    Color pickerColor = _selectedColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text('Escolher Cor', style: AppTheme.textTheme.titleLarge?.copyWith(color: Colors.white)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) => pickerColor = color,
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false, // Alpha não é usualmente necessário para cores de categoria
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [], // Remove labels como RGB, HSV etc.
              pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8.0)),
              hexInputBar: false, // Ocultar input hexadecimal
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text('CONFIRMAR', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() => _selectedColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Categoria' : 'Nova Categoria',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isEditing && !widget.categoryToEdit!.isDefault)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              tooltip: 'Excluir Categoria',
              onPressed: _isLoading ? null : _deleteCategory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Nome da Categoria
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: AppTheme.inputDecoration(
                        labelText: 'Nome da Categoria',
                        hintText: 'Ex: Estudos, Saúde, Lazer',
                        prefixIcon: Icons.label_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira um nome para a categoria.';
                        }
                        if (value.trim().length > 30) {
                           return 'O nome não pode exceder 30 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Seleção de Ícone
                    Text('Ícone', style: AppTheme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showIconPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(_selectedIcon, color: _selectedColor, size: 28),
                                const SizedBox(width: 16),
                                Text(
                                  'Alterar Ícone',
                                  style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Seleção de Cor
                    Text('Cor', style: AppTheme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showColorPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: _selectedColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.5))
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Alterar Cor',
                                  style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botão Salvar
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined),
                      label: Text(_isEditing ? 'Salvar Alterações' : 'Criar Categoria'),
                      style: AppTheme.primaryButton,
                      onPressed: _isLoading ? null : _saveCategory,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Removido _buildSectionCard pois a estrutura foi simplificada
// Removida a seção de "Tarefas Associadas" e a importação de 'select_tasks_screen.dart'
// pois a gestão de associação será feita no Hábito/Tarefa.
