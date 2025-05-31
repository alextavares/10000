import 'package:flutter/material.dart';

enum FilterType { all, completed, pending, overdue }
enum SortBy { title, dueDate, category, createdDate }
enum SortOrder { ascending, descending }

class FilterOptions {
  final FilterType filterType;
  final String? selectedCategory;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final DateTimeRange? dateRange;
  final bool showOnlyWithReminders;

  FilterOptions({
    this.filterType = FilterType.all,
    this.selectedCategory,
    this.sortBy = SortBy.dueDate,
    this.sortOrder = SortOrder.ascending,
    this.dateRange,
    this.showOnlyWithReminders = false,
  });

  FilterOptions copyWith({
    FilterType? filterType,
    String? selectedCategory,
    SortBy? sortBy,
    SortOrder? sortOrder,
    DateTimeRange? dateRange,
    bool? showOnlyWithReminders,
  }) {
    return FilterOptions(
      filterType: filterType ?? this.filterType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      dateRange: dateRange ?? this.dateRange,
      showOnlyWithReminders: showOnlyWithReminders ?? this.showOnlyWithReminders,
    );
  }
}

class FilterScreen extends StatefulWidget {
  final FilterOptions initialOptions;

  const FilterScreen({
    super.key,
    required this.initialOptions,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterOptions _currentOptions;

  final List<String> _categories = [
    'Trabalho',
    'Pessoal',
    'Estudo',
    'Saúde',
    'Finanças',
    'Casa',
    'Outros'
  ];

  @override
  void initState() {
    super.initState();
    _currentOptions = widget.initialOptions;
  }

  void _updateFilterType(FilterType filterType) {
    setState(() {
      _currentOptions = _currentOptions.copyWith(filterType: filterType);
    });
  }

  void _updateCategory(String? category) {
    setState(() {
      _currentOptions = _currentOptions.copyWith(selectedCategory: category);
    });
  }

  void _updateSortBy(SortBy sortBy) {
    setState(() {
      _currentOptions = _currentOptions.copyWith(sortBy: sortBy);
    });
  }

  void _updateSortOrder(SortOrder sortOrder) {
    setState(() {
      _currentOptions = _currentOptions.copyWith(sortOrder: sortOrder);
    });
  }

  void _updateDateRange(DateTimeRange? dateRange) {
    setState(() {
      _currentOptions = _currentOptions.copyWith(dateRange: dateRange);
    });
  }

  void _updateShowOnlyWithReminders(bool value) {
    setState(() {
      _currentOptions = _currentOptions.copyWith(showOnlyWithReminders: value);
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _currentOptions.dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE91E63),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE91E63),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _updateDateRange(picked);
    }
  }

  void _clearFilters() {
    setState(() {
      _currentOptions = FilterOptions();
    });
  }

  void _applyFilters() {
    Navigator.of(context).pop(_currentOptions);
  }

  String _getFilterTypeLabel(FilterType type) {
    switch (type) {
      case FilterType.all:
        return 'Todos';
      case FilterType.completed:
        return 'Concluídos';
      case FilterType.pending:
        return 'Pendentes';
      case FilterType.overdue:
        return 'Atrasados';
    }
  }

  String _getSortByLabel(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.title:
        return 'Título';
      case SortBy.dueDate:
        return 'Data de vencimento';
      case SortBy.category:
        return 'Categoria';
      case SortBy.createdDate:
        return 'Data de criação';
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
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Filtros',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Limpar',
              style: TextStyle(color: Color(0xFFE91E63)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter
            _buildSectionTitle('Status'),
            const SizedBox(height: 12),
            ...FilterType.values.map((type) => _buildFilterTypeOption(type)),
            
            const SizedBox(height: 24),
            
            // Category Filter
            _buildSectionTitle('Categoria'),
            const SizedBox(height: 12),
            _buildCategoryDropdown(),
            
            const SizedBox(height: 24),
            
            // Date Range Filter
            _buildSectionTitle('Período'),
            const SizedBox(height: 12),
            _buildDateRangeSelector(),
            
            const SizedBox(height: 24),
            
            // Sort Options
            _buildSectionTitle('Ordenação'),
            const SizedBox(height: 12),
            _buildSortByDropdown(),
            const SizedBox(height: 12),
            _buildSortOrderToggle(),
            
            const SizedBox(height: 24),
            
            // Additional Options
            _buildSectionTitle('Opções Adicionais'),
            const SizedBox(height: 12),
            _buildReminderToggle(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
            top: BorderSide(color: Colors.grey[800]!),
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Aplicar Filtros',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFilterTypeOption(FilterType type) {
    final isSelected = _currentOptions.filterType == type;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _updateFilterType(type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE91E63).withOpacity(0.2) : Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFE91E63) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? const Color(0xFFE91E63) : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                _getFilterTypeLabel(type),
                style: TextStyle(
                  color: isSelected ? const Color(0xFFE91E63) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _currentOptions.selectedCategory,
          isExpanded: true,
          dropdownColor: Colors.grey[850],
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          hint: const Text(
            'Todas as categorias',
            style: TextStyle(color: Colors.grey),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todas as categorias'),
            ),
            ..._categories.map((category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            )),
          ],
          onChanged: _updateCategory,
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Color(0xFFE91E63)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _currentOptions.dateRange == null
                    ? 'Selecionar período'
                    : '${_currentOptions.dateRange!.start.day}/${_currentOptions.dateRange!.start.month} - ${_currentOptions.dateRange!.end.day}/${_currentOptions.dateRange!.end.month}',
                style: TextStyle(
                  color: _currentOptions.dateRange == null ? Colors.grey : Colors.white,
                ),
              ),
            ),
            if (_currentOptions.dateRange != null)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () => _updateDateRange(null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortByDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortBy>(
          value: _currentOptions.sortBy,
          isExpanded: true,
          dropdownColor: Colors.grey[850],
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: SortBy.values.map((sortBy) => DropdownMenuItem<SortBy>(
            value: sortBy,
            child: Text(_getSortByLabel(sortBy)),
          )).toList(),
          onChanged: (value) => _updateSortBy(value!),
        ),
      ),
    );
  }

  Widget _buildSortOrderToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.sort, color: Color(0xFFE91E63)),
          const SizedBox(width: 12),
          const Text(
            'Ordem:',
            style: TextStyle(color: Colors.white),
          ),
          const Spacer(),
          ToggleButtons(
            isSelected: [
              _currentOptions.sortOrder == SortOrder.ascending,
              _currentOptions.sortOrder == SortOrder.descending,
            ],
            onPressed: (index) {
              _updateSortOrder(index == 0 ? SortOrder.ascending : SortOrder.descending);
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: const Color(0xFFE91E63),
            color: Colors.grey,
            constraints: const BoxConstraints(minWidth: 60, minHeight: 36),
            children: const [
              Icon(Icons.arrow_upward, size: 18),
              Icon(Icons.arrow_downward, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Color(0xFFE91E63)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Apenas com lembretes',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Switch(
            value: _currentOptions.showOnlyWithReminders,
            onChanged: _updateShowOnlyWithReminders,
            activeColor: const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }
}
