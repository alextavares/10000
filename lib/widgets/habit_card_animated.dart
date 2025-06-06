import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/utils/responsive/responsive.dart';

class HabitCardAnimated extends StatefulWidget {
  final Habit habit;
  final Function()? onTap;
  final Function(bool completed)? onToggleCompletion;
  final Function()? onDelete;

  const HabitCardAnimated({
    super.key,
    required this.habit,
    this.onTap,
    this.onToggleCompletion,
    this.onDelete,
  });

  @override
  State<HabitCardAnimated> createState() => _HabitCardAnimatedState();
}

class _HabitCardAnimatedState extends State<HabitCardAnimated>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _progressAnimation;

  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.habit.isCompletedToday();

    // Animação de escala para o card
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Animação do checkbox
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _isCompleted ? 1.0 : 0.0,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    // Animação da barra de progresso
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );

    // Iniciar animação de progresso
    _progressController.forward();
  }
  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleCheckboxChange(bool? value) {
    if (value == null) return;

    setState(() {
      _isCompleted = value;
    });

    if (value) {
      _checkController.forward();
      // Vibração suave ao completar (se disponível)
      HapticFeedback.lightImpact();
    } else {
      _checkController.reverse();
    }

    if (widget.onToggleCompletion != null) {
      widget.onToggleCompletion!(value);
    }
  }

  // Calcular progresso do hábito (exemplo: baseado em completions semanais)
  double _calculateProgress() {
    // Aqui você pode implementar sua lógica de progresso
    // Por exemplo: percentual de dias completados na semana
    return 0.7; // 70% como exemplo
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildCard(context, progress),
        );
      },
    );
  }
  Widget _buildCard(BuildContext context, double progress) {
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
      child: Stack(
        children: [
          // Barra de progresso de fundo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    widget.habit.color.withValues(alpha: 0.2),
                    widget.habit.color.withValues(alpha: 0.05),
                  ],
                  stops: [
                    _progressAnimation.value * progress,
                    _progressAnimation.value * progress,
                  ],
                ),
              ),
            ),
          ),
          // Card principal
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.habit.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _handleTap,
                child: Padding(
                  padding: cardPadding,
                  child: _buildCardContent(context, progress),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCardContent(BuildContext context, double progress) {
    return Row(
      children: [
        // Ícone animado
        AnimatedBuilder(
          animation: _checkAnimation,
          builder: (context, child) {
            return Container(
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
                color: widget.habit.color.withValues(
                  alpha: 0.2 + (_checkAnimation.value * 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isCompleted
                    ? [
                        BoxShadow(
                          color: widget.habit.color.withValues(alpha: 0.3),
                          blurRadius: 8 * _checkAnimation.value,
                          spreadRadius: 2 * _checkAnimation.value,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                widget.habit.icon,
                color: widget.habit.color,
                size: Responsive.value<double>(
                  context: context,
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ) * (1 + (_checkAnimation.value * 0.1)),
              ),
            );
          },
        ),
        SizedBox(
          width: Responsive.value<double>(
            context: context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        ),        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e badges
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.habit.title,
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
                    ),
                  ),
                  // Badges de streak e progresso
                  _buildBadges(context, progress),
                ],
              ),
              if (widget.habit.description != null &&
                  widget.habit.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.habit.description!,
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
              // Barra de progresso visual
              const SizedBox(height: 8),
              _buildProgressBar(context, progress),
            ],
          ),
        ),
        // Checkbox animado
        if (widget.onToggleCompletion != null) _buildAnimatedCheckbox(context),
      ],
    );
  }
  Widget _buildBadges(BuildContext context, double progress) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge de progresso
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: widget.habit.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              color: widget.habit.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Badge de streak
        if (widget.habit.streak > 0)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: widget.habit.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.habit.color.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 14,
                  color: widget.habit.color,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.habit.streak}',
                  style: TextStyle(
                    color: widget.habit.color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  Widget _buildProgressBar(BuildContext context, double progress) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso semanal',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value * progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.habit.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedCheckbox(BuildContext context) {
    return Transform.scale(
      scale: Responsive.value<double>(
        context: context,
        mobile: 1.0,
        tablet: 1.1,
        desktop: 1.2,
      ),
      child: AnimatedBuilder(
        animation: _checkAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + (_checkAnimation.value * 0.2),
            child: Checkbox(
              value: _isCompleted,
              onChanged: _handleCheckboxChange,
              activeColor: widget.habit.color,
              checkColor: Colors.white,
              side: BorderSide(
                color: widget.habit.color,
                width: 2,
              ),
            ),
          );
        },
      ),
    );
  }
}
