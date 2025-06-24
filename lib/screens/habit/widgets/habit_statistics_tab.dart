import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/logger.dart';

class HabitStatisticsTab extends StatefulWidget {
  final Habit habit;

  const HabitStatisticsTab({
    super.key,
    required this.habit,
  });

  @override
  State<HabitStatisticsTab> createState() => _HabitStatisticsTabState();
}

class _HabitStatisticsTabState extends State<HabitStatisticsTab> {
  String _selectedPeriod = 'Mês'; // Padrão para Mês
  List<BarChartGroupData> _barChartData = [];
  double _maxYForChart = 5; // Valor inicial padrão para maxY
  bool _isLoadingChartData = true;
  Map<int, String> _bottomTitlesCache = {}; // Cache para títulos inferiores

  @override
  void initState() {
    super.initState();
    // Garante que 'pt_BR' está inicializado para DateFormat
    initializeDateFormatting('pt_BR', null).then((_) {
      _updateChartData();
    });
  }

  @override
  void didUpdateWidget(covariant HabitStatisticsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habit.id != oldWidget.habit.id ||
        widget.habit.completionHistory.length != oldWidget.habit.completionHistory.length ||
        // Adicionar uma verificação mais robusta se o conteúdo de completionHistory mudou
        !mapEquals(widget.habit.completionHistory, oldWidget.habit.completionHistory)
       ) {
      _updateChartData();
    }
  }

  // Função para obter o número da semana (ISO 8601)
  int _weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D", "pt_BR").format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
        woy = _weeksInYear(date.year - 1);
    } else if (woy > _weeksInYear(date.year)) {
        woy = 1;
    }
    return woy;
  }

  int _weeksInYear(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D", "pt_BR").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }


  Future<void> _updateChartData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingChartData = true;
      _bottomTitlesCache.clear();
    });

    List<BarChartGroupData> barGroups = [];
    double tempMaxY = 0.0; // Iniciar com 0, será ajustado

    final history = widget.habit.completionHistory;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final habitStartDate = DateTime(widget.habit.startDate.year, widget.habit.startDate.month, widget.habit.startDate.day);

    if (_selectedPeriod == 'Semana') {
      Map<String, int> weeklyCompletions = {}; // YYYY-WW -> contagem
      int numberOfWeeks = 12; // Mostrar as últimas 12 semanas

      for (int i = numberOfWeeks - 1; i >= 0; i--) {
        DateTime dateInTargetWeek = today.subtract(Duration(days: i * 7));
        DateTime weekStart = dateInTargetWeek.subtract(Duration(days: dateInTargetWeek.weekday - 1));
        weekStart = DateTime(weekStart.year, weekStart.month, weekStart.day);

        // Não mostrar semanas antes da data de início do hábito
        if (weekStart.add(const Duration(days: 6)).isBefore(habitStartDate)) continue;


        String weekKey = "${weekStart.year}-${_weekNumber(weekStart).toString().padLeft(2, '0')}";
        weeklyCompletions.putIfAbsent(weekKey, () => 0);

        for (int d = 0; d < 7; d++) {
          DateTime currentDay = weekStart.add(Duration(days: d));
           // Considerar apenas dias a partir da data de início do hábito e até hoje
          if (currentDay.isBefore(habitStartDate) || currentDay.isAfter(today)) continue;

          if (history[currentDay] == true && widget.habit.isDueToday(currentDay)) {
            weeklyCompletions[weekKey] = weeklyCompletions[weekKey]! + 1;
          }
        }
      }

      var sortedWeeks = weeklyCompletions.keys.toList()..sort();
      int x = 0;
      for (var weekKey in sortedWeeks) {
        final completions = weeklyCompletions[weekKey]!.toDouble();
        if (completions > tempMaxY) tempMaxY = completions;
        barGroups.add(
          BarChartGroupData(x: x, barRods: [
            BarChartRodData(toY: completions, color: widget.habit.color, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))
          ])
        );
        _bottomTitlesCache[x] = "S${weekKey.split('-').last}"; // Ex: S34
        x++;
      }

    } else if (_selectedPeriod == 'Mês')
    {
      Map<String, int> monthlyCompletions = {}; // YYYY-MM -> contagem
      int numberOfMonths = 6; // Mostrar os últimos 6 meses

      for (int i = numberOfMonths - 1; i >= 0; i--) {
          DateTime monthDate = DateTime(today.year, today.month - i, 1);
          // Não mostrar meses antes da data de início do hábito
          DateTime firstDayOfHabitMonth = DateTime(habitStartDate.year, habitStartDate.month, 1);
          if (monthDate.isBefore(firstDayOfHabitMonth)) continue;

          String monthKey = DateFormat('yyyy-MM', 'pt_BR').format(monthDate);
          monthlyCompletions.putIfAbsent(monthKey, () => 0);

          DateTime firstDayCurrentMonth = DateTime(monthDate.year, monthDate.month, 1);
          DateTime lastDayCurrentMonth = DateTime(monthDate.year, monthDate.month + 1, 0);

          history.forEach((date, completed) {
            DateTime dateOnly = DateTime(date.year, date.month, date.day);
            if (completed &&
                !dateOnly.isBefore(firstDayCurrentMonth) &&
                !dateOnly.isAfter(lastDayCurrentMonth) &&
                !dateOnly.isBefore(habitStartDate) && // Garante que não conta antes do início do hábito
                !dateOnly.isAfter(today) && // Garante que não conta dias futuros
                widget.habit.isDueToday(date)) {
              monthlyCompletions[monthKey] = (monthlyCompletions[monthKey] ?? 0) + 1;
            }
          });
      }
      int x = 0;
      var sortedMonths = monthlyCompletions.keys.toList()..sort();
      for (var monthKey in sortedMonths) {
         final completions = monthlyCompletions[monthKey]!.toDouble();
        if (completions > tempMaxY) tempMaxY = completions;
        barGroups.add(
          BarChartGroupData(x: x, barRods: [
            BarChartRodData(toY: completions, color: widget.habit.color, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))
          ])
        );
        _bottomTitlesCache[x] = DateFormat('MMM', 'pt_BR').format(DateFormat('yyyy-MM', 'pt_BR').parse(monthKey)).toUpperCase();
        x++;
      }

    } else if (_selectedPeriod == 'Ano') {
      Map<int, int> yearlyCompletions = {}; // Mês (1-12) -> contagem
      for (int month = 1; month <= 12; month++) {
        DateTime firstDayOfMonth = DateTime(today.year, month, 1);
        DateTime lastDayOfMonth = DateTime(today.year, month + 1, 0);

        // Não mostrar meses antes da data de início do hábito se for no mesmo ano
        if (today.year == habitStartDate.year && month < habitStartDate.month) continue;
        // Não mostrar meses futuros
        if (today.year == firstDayOfMonth.year && month > today.month) continue;

        yearlyCompletions[month] = 0;
        history.forEach((date, completed) {
           DateTime dateOnly = DateTime(date.year, date.month, date.day);
          if (completed &&
              dateOnly.year == today.year &&
              dateOnly.month == month &&
              !dateOnly.isBefore(habitStartDate) &&
              !dateOnly.isAfter(today) &&
              widget.habit.isDueToday(date)) {
            yearlyCompletions[month] = (yearlyCompletions[month] ?? 0) + 1;
          }
        });
      }
      yearlyCompletions.forEach((month, completionsCount) {
        final yValue = completionsCount.toDouble();
        if (yValue > tempMaxY) tempMaxY = yValue;
        barGroups.add(
          BarChartGroupData(x: month -1, barRods: [
            BarChartRodData(toY: yValue, color: widget.habit.color, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))
          ])
        );
         _bottomTitlesCache[month-1] = DateFormat('MMM', 'pt_BR').format(DateTime(today.year, month)).substring(0,3).toUpperCase();
      });
    }

    if (mounted) {
      setState(() {
        _barChartData = barGroups;
        _maxYForChart = (tempMaxY < 5 && tempMaxY > 0) ? 5.0 : (tempMaxY / 5).ceil() * 5.0;
        if (tempMaxY == 0) _maxYForChart = 5; // Default Y-axis if no data
        _isLoadingChartData = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Habit score
          _buildHabitScore(),
          
          const SizedBox(height: 24),
          
          // Streak comparison
          _buildStreakComparison(),
          
          const SizedBox(height: 24),
          
          // Completion times
          _buildCompletionTimes(),
          
          const SizedBox(height: 24),
          
          // Success chart (placeholder)
          _buildSuccessChart(),
          
          const SizedBox(height: 24),
          
          // Streak challenges
          _buildStreakChallenges(),
        ],
      ),
    );
  }
  
  Widget _buildHabitScore() {
    final completionRate = widget.habit.getCompletionRate() * 100;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: widget.habit.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Pontuação de hábito',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Circular progress indicator
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: completionRate / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(widget.habit.color),
                ),
                Center(
                  child: Text(
                    '${completionRate.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreakComparison() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                color: widget.habit.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Série',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    'Atual',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.habit.streak} DIAS',
                    style: TextStyle(
                      color: widget.habit.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[800],
              ),
              Column(
                children: [
                  const Text(
                    'Melhor',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.habit.longestStreak} DIA${widget.habit.longestStreak != 1 ? 'S' : ''}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompletionTimes() {
    final now = DateTime.now();
    final thisWeek = _getCompletionsThisWeek();
    final thisMonth = _getCompletionsThisMonth();
    final thisYear = _getCompletionsThisYear();
    final total = widget.habit.totalCompletions; // Usar o campo totalCompletions do hábito
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: widget.habit.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Vezes concluída',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCompletionRow('Esta semana', thisWeek),
          const SizedBox(height: 12),
          _buildCompletionRow('Este mês', thisMonth),
          const SizedBox(height: 12),
          _buildCompletionRow('Este ano', thisYear),
          const SizedBox(height: 12),
          _buildCompletionRow('Total', total),
        ],
      ),
    );
  }
  
  Widget _buildCompletionRow(String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuccessChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Period selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPeriodButton('Semana'),
              const SizedBox(width: 16),
              _buildPeriodButton('Mês'),
              const SizedBox(width: 16),
              _buildPeriodButton('Ano'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                color: widget.habit.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Sucesso / Falha',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Placeholder for chart
          Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart, // Alterado de donut_large
                    size: 60, // Reduzido o tamanho do ícone de placeholder
                    color: widget.habit.color.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isLoadingChartData ? 'Carregando gráfico...' : 'Sem dados para exibir no período.',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0), // Adiciona padding para os títulos dos eixos
      child: BarChart(
        BarChartData(
          maxY: _maxYForChart,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppTheme.surfaceColor.withOpacity(0.9),
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String label = _bottomTitlesCache[group.x.toInt()] ?? '';
                 if (_selectedPeriod == 'Mês') {
                    DateTime monthDate = DateFormat('MMM', 'pt_BR').parse(label);
                    label = DateFormat('MMMM yyyy', 'pt_BR').format(DateTime(DateTime.now().year, monthDate.month));
                     // Ajuste para anos anteriores se necessário
                    if (_barChartData.length == 6) { // Se mostrando últimos 6 meses
                        DateTime baseDate = DateTime(DateTime.now().year, DateTime.now().month - (5 - group.x), 1);
                        label = DateFormat('MMMM yyyy', 'pt_BR').format(baseDate);
                    }

                } else if (_selectedPeriod == 'Ano') {
                    label = DateFormat('MMMM yyyy', 'pt_BR').format(DateTime(DateTime.now().year, group.x + 1));
                } else if (_selectedPeriod == 'Semana') {
                    // Para semanas, o label já é SXX. Podemos adicionar o ano.
                    // Isso requer mais lógica para determinar o ano correto da semana X.
                    // Por simplicidade, mantemos "Semana XX".
                    label = "Semana ${label.substring(1)}";
                }

                return BarTooltipItem(
                  '$label\n',
                  TextStyle(color: widget.habit.color, fontWeight: FontWeight.bold, fontSize: 13),
                  children: <TextSpan>[
                    TextSpan(
                      text: rod.toY.toInt().toString() + (rod.toY.toInt() == 1 ? " vez" : " vezes"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            handleBuiltInTouches: true,
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _getBottomTitles,
                reservedSize: 38,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32, // Aumentado para caber números maiores
                interval: (_maxYForChart / 5).ceilToDouble() > 0 ? (_maxYForChart / 5).ceilToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  if (value == 0 && _maxYForChart > 0 && _barChartData.any((group) => group.barRods.any((rod) => rod.toY > 0))) return Container();
                  if (value == meta.max && _maxYForChart > 0) return Container();
                  if (value > _maxYForChart) return Container(); // Não mostrar ticks acima do maxY
                  return Text(value.toInt().toString(), style: TextStyle(color: Colors.grey[500], fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[700]!, width: 1),
              left: BorderSide(color: Colors.grey[700]!, width: 1),
            )
          ),
          barGroups: _barChartData,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (_maxYForChart / 5).ceilToDouble() > 0 ? (_maxYForChart / 5).ceilToDouble() : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[800]!,
                strokeWidth: 0.5,
              );
            },
          ),
          alignment: BarChartAlignment.spaceAround,
        ),
      ),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    final style = TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500, fontSize: 10);
    String text = _bottomTitlesCache[value.toInt()] ?? '';

    // Lógica para mostrar menos títulos se houver muitos para evitar sobreposição
    if (_selectedPeriod == 'Semana' && _barChartData.length > 7) {
      if (value.toInt() % ((_barChartData.length / 5).ceil()) != 0 && value.toInt() != _barChartData.length -1 && value.toInt() != 0)  {
        return Container();
      }
    } else if (_selectedPeriod == 'Ano' && _barChartData.length > 6) { // Para 12 meses
         if (value.toInt() % 2 != 0 ) { // Mostra Jan, Mar, Mai, Jul, Set, Nov
            return Container();
         }
    } else if (_selectedPeriod == 'Mês' && _barChartData.length > 4) { // Para 6 meses
         if (value.toInt() % 1 != 0 && value.toInt() != _barChartData.length -1 && value.toInt() != 0) { // Mostra todos se forem poucos, senão alterna
            return Container();
         }
    }


    return SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text(text, style: style));
  }
  
  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            _selectedPeriod = period;
            _updateChartData(); // Recarregar dados do gráfico ao mudar período
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduzido padding horizontal
        decoration: BoxDecoration(
          color: isSelected ? widget.habit.color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? widget.habit.color : Colors.grey[700]!,
          ),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? widget.habit.color : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildStreakChallenges() {
    final challenges = [
      {'days': 1, 'completed': widget.habit.longestStreak >= 1},
      {'days': 7, 'completed': widget.habit.longestStreak >= 7},
      {'days': 15, 'completed': widget.habit.longestStreak >= 15},
      {'days': 30, 'completed': widget.habit.longestStreak >= 30},
      {'days': 60, 'completed': widget.habit.longestStreak >= 60},
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.military_tech,
                color: widget.habit.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Desafio de série',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: challenges.map((challenge) {
              final isCompleted = challenge['completed'] as bool;
              final days = challenge['days'] as int;
              
              return Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? widget.habit.color // Cor sólida para completo
                          : AppTheme.surfaceColor.withOpacity(0.5), // Mais suave para incompleto
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? widget.habit.color : Colors.grey[700]!,
                        width: 1.5,
                      ),
                       boxShadow: isCompleted ? [
                          BoxShadow(
                            color: widget.habit.color.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 1
                          )
                        ] : [],
                    ),
                    child: Center(
                      child: Icon(
                        isCompleted ? Icons.check : Icons.lock_outline, // Ícone de check para completo
                        color: isCompleted ? Colors.white : Colors.grey[500],
                        size: isCompleted? 20 : 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$days dia${days > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: isCompleted ? widget.habit.color : Colors.grey[500],
                      fontSize: 12,
                      fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
 int _getCompletionsThisWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // ISO 8601: Monday is 1, Sunday is 7.
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    int count = 0;
    
    widget.habit.completionHistory.forEach((date, completed) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (completed &&
          !normalizedDate.isBefore(startOfWeek) &&
          !normalizedDate.isAfter(endOfWeek) &&
          widget.habit.isDueToday(date)) {
        count++;
      }
    });
    return count;
  }
  
  int _getCompletionsThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0); // Last day of current month
    int count = 0;
    
    widget.habit.completionHistory.forEach((date, completed) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (completed &&
          !normalizedDate.isBefore(startOfMonth) &&
          !normalizedDate.isAfter(endOfMonth) &&
          widget.habit.isDueToday(date)) {
        count++;
      }
    });
    return count;
  }
  
  int _getCompletionsThisYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    int count = 0;
    
    widget.habit.completionHistory.forEach((date, completed) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (completed &&
          !normalizedDate.isBefore(startOfYear) &&
          !normalizedDate.isAfter(endOfYear) &&
          widget.habit.isDueToday(date)) {
        count++;
      }
    });
    return count;
  }
}

// Helper para comparar maps, usado em didUpdateWidget
bool mapEquals<T, U>(Map<T, U>? a, Map<T, U>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) {
      return false;
    }
  }
  return true;
}
