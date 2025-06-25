import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/screens/habit/habit_details_screen.dart';
import 'package:myapp/utils/responsive/responsive.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final Function()? onTap;
  final Function(bool completed)? onToggleCompletion;
  final Function()? onDelete;
  final Function()? onEdit; // Adicionado callback para edição

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onToggleCompletion,
    this.onDelete,
    this.onEdit, // Adicionado callback para edição
  });

  @override
  Widget build(BuildContext context) {
    final cardMargin = EdgeInsets.symmetric(
      horizontal: Responsive.value<double>(
        context: context,
        mobile: 0,
        tablet: 20,
        desktop: 0,
      ),
      vertical: 6,
    );

    final cardPadding = EdgeInsets.all(
      Responsive.value<double>(
        context: context,
        mobile: 12,
        tablet: 20,
        desktop: 24,
      ),
    );

    return Padding(
      padding: cardMargin,
      child: Slidable(
        key: Key(habit.id), // Chave única para o Slidable
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                if (onEdit != null) {
                  onEdit!();
                } else {
                  // Comportamento padrão se onEdit não for fornecido
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HabitDetailsScreen(habitId: habit.id, initialTab: 1), // Assumindo que 1 é o índice da aba de edição
                    ),
                  );
                }
              },
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Editar',
            ),
            SlidableAction(
              onPressed: (context) {
                if (onDelete != null) {
                  onDelete!();
                }
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Excluir',
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: habit.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: habit.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap ?? () { // Usar o onTap fornecido ou o padrão
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HabitDetailsScreen(habitId: habit.id),
                  ),
                );
              },
              child: Padding(
                padding: cardPadding,
                child: Row(
                  children: [
                    Container(
                      width: Responsive.value<double>(
                        context: context,
                        mobile: 48,
                        tablet: 56,
                        desktop: 64,
                      ),
                      height: Responsive.value<double>(
                        context: context,
                        mobile: 48,
                        tablet: 56,
                        desktop: 64,
                      ),
                      decoration: BoxDecoration(
                        color: habit.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        habit.icon,
                        color: habit.color,
                        size: Responsive.value<double>(
                          context: context,
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.value<double>(
                      context: context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    )),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  habit.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Responsive.value<double>(
                                      context: context,
                                      mobile: 16,
                                      tablet: 18,
                                      desktop: 20,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (habit.streak > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: habit.color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: habit.color.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.local_fire_department,
                                        size: 14,
                                        color: habit.color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${habit.streak}',
                                        style: TextStyle(
                                          color: habit.color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (habit.description != null && habit.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              habit.description!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: Responsive.value<double>(
                                  context: context,
                                  mobile: 14,
                                  tablet: 15,
                                  desktop: 16,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (habit.description == null || habit.description!.isEmpty)
                            const SizedBox(height: 2)
                          else
                            const SizedBox(height: 4),
                          Text(
                            _getFrequencyText(habit),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onToggleCompletion != null)
                      Transform.scale(
                        scale: Responsive.value<double>(
                          context: context,
                          mobile: 1.0,
                          tablet: 1.1,
                          desktop: 1.2,
                        ),
                        child: Checkbox(
                          value: habit.isCompletedToday(DateTime.now()), // Passar a data selecionada se disponível, senão DateTime.now()
                          onChanged: (bool? value) {
                            if (value != null) {
                              onToggleCompletion!(value);
                            }
                          },
                          activeColor: habit.color,
                          checkColor: Colors.white,
                          side: BorderSide(
                            color: habit.color,
                            width: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getFrequencyText(Habit habit) {
    // Lógica para obter o texto da frequência (mantida como estava)
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return 'Diário';
      case HabitFrequency.weekly:
        if (habit.daysOfWeek != null && habit.daysOfWeek!.isNotEmpty) {
          // Ordenar e converter para nomes dos dias
          List<String> dayNames = habit.daysOfWeek!
              .map((d) => ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][d - 1])
              .toList();
          if (dayNames.length == 7) return 'Diário';
          if (dayNames.length > 3) return '${dayNames.length}x por semana';
          return dayNames.join(', ');
        }
        return 'Semanal';
      case HabitFrequency.monthly:
        if (habit.daysOfMonth != null && habit.daysOfMonth!.isNotEmpty) {
          return '${habit.daysOfMonth!.length}x por mês';
        }
        return 'Mensal';
      case HabitFrequency.someTimesPerPeriod:
        if (habit.timesPerPeriod != null && habit.periodType != null) {
          final period = habit.periodType == 'SEMANA' ? 'semana' :
                         habit.periodType == 'MÊS' ? 'mês' : 'ano';
          return '${habit.timesPerPeriod}x por $period';
        }
        return 'Personalizado';
      case HabitFrequency.repeat:
        if (habit.repeatEveryDays != null) {
          return 'A cada ${habit.repeatEveryDays} dias';
        }
        if (habit.alternateDays == true) {
          return 'Dias alternados';
        }
        return 'Repetir';
      default:
        return 'Personalizado';
    }
  }
}

// Adicionar esta extensão para facilitar a obtenção da cor com alfa
extension ColorAlpha on Color {
  Color withValues({int? alpha, int? red, int? green, int? blue}) {
    return Color.fromARGB(
      alpha ?? this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}
