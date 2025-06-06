import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget para exibir um gráfico de linha animado
class AnimatedLineChart extends StatefulWidget {
  final Map<DateTime, double> data;
  final Color lineColor;
  final double height;
  final String? title;
  
  const AnimatedLineChart({
    super.key,
    required this.data,
    required this.lineColor,
    this.height = 200,
    this.title,
  });
  
  @override
  State<AnimatedLineChart> createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<AnimatedLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text('Sem dados disponíveis'),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _LineChartPainter(
                  data: widget.data,
                  lineColor: widget.lineColor,
                  progress: _animation.value,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final Map<DateTime, double> data;
  final Color lineColor;
  final double progress;
  
  _LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    final maxValue = sortedEntries
        .map((e) => e.value)
        .reduce((a, b) => math.max(a, b));
    
    final padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    
    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;
    
    for (int i = 0; i <= 4; i++) {
      final y = padding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }
    
    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final fillPath = Path();
    
    for (int i = 0; i < sortedEntries.length; i++) {
      final x = padding + (chartWidth * i / (sortedEntries.length - 1));
      final y = padding + chartHeight * (1 - sortedEntries[i].value / maxValue);
      final animatedY = size.height - (size.height - y) * progress;
      
      if (i == 0) {
        path.moveTo(x, animatedY);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, animatedY);
      } else {
        path.lineTo(x, animatedY);
        fillPath.lineTo(x, animatedY);
      }
    }
    
    // Complete fill path
    fillPath.lineTo(size.width - padding, size.height - padding);
    fillPath.close();
    
    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < sortedEntries.length; i++) {
      final x = padding + (chartWidth * i / (sortedEntries.length - 1));
      final y = padding + chartHeight * (1 - sortedEntries[i].value / maxValue);
      final animatedY = size.height - (size.height - y) * progress;
      
      canvas.drawCircle(Offset(x, animatedY), 4, pointPaint);
    }
  }
  
  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Widget de heatmap estilo GitHub
class YearHeatmap extends StatefulWidget {
  final Map<int, Map<int, double>> data;
  final Color baseColor;
  
  const YearHeatmap({
    super.key,
    required this.data,
    this.baseColor = Colors.green,
  });
  
  @override
  State<YearHeatmap> createState() => _YearHeatmapState();
}

class _YearHeatmapState extends State<YearHeatmap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: 120,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: CustomPaint(
              size: Size(53 * 8.0, 120),
              painter: _HeatmapPainter(
                data: widget.data,
                baseColor: widget.baseColor,
                progress: _animation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final Map<int, Map<int, double>> data;
  final Color baseColor;
  final double progress;
  
  _HeatmapPainter({
    required this.data,
    required this.baseColor,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = 6.0;
    final cellPadding = 2.0;
    final now = DateTime.now();
    
    // Draw month labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 
                   'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    
    // Draw cells
    for (int week = 0; week < 53; week++) {
      for (int day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: (52 - week) * 7 + (6 - day)));
        final month = date.month;
        final dayOfMonth = date.day;
        
        final value = data[month]?[dayOfMonth] ?? 0.0;
        final animatedValue = value * progress;
        
        final x = week * (cellSize + cellPadding);
        final y = day * (cellSize + cellPadding) + 20;
        
        final rect = Rect.fromLTWH(x, y, cellSize, cellSize);
        
        final paint = Paint()
          ..color = _getColorForValue(animatedValue)
          ..style = PaintingStyle.fill;
        
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          paint,
        );
        
        // Draw month label at the beginning of each month
        if (dayOfMonth == 1 && day == date.weekday % 7) {
          textPainter.text = TextSpan(
            text: months[month - 1],
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(x, 0));
        }
      }
    }
    
    // Draw day labels
    final days = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    for (int i = 0; i < 7; i++) {
      if (i % 2 == 0) { // Show every other day to save space
        textPainter.text = TextSpan(
          text: days[i],
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[600],
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas, 
          Offset(-15, i * (cellSize + cellPadding) + 20),
        );
      }
    }
  }
  
  Color _getColorForValue(double value) {
    if (value == 0) return Colors.grey[200]!;
    if (value < 0.25) return baseColor.withValues(alpha: 0.3);
    if (value < 0.5) return baseColor.withValues(alpha: 0.5);
    if (value < 0.75) return baseColor.withValues(alpha: 0.7);
    return baseColor;
  }
  
  @override
  bool shouldRepaint(_HeatmapPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Widget de card de estatística animado
class AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;
  
  const AnimatedStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });
  
  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withValues(alpha: 0.1),
                  widget.color.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 24,
                      ),
                    ),
                    if (widget.onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<int>(
                  duration: const Duration(milliseconds: 1000),
                  tween: IntTween(
                    begin: 0,
                    end: int.tryParse(widget.value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                  ),
                  builder: (context, value, child) {
                    final displayValue = widget.value.contains('%') 
                        ? '$value%'
                        : value.toString();
                    return Text(
                      displayValue,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    );
                  },
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget circular de progresso animado
class AnimatedCircularProgress extends StatefulWidget {
  final double value;
  final Color color;
  final double size;
  final String? centerText;
  
  const AnimatedCircularProgress({
    super.key,
    required this.value,
    required this.color,
    this.size = 100,
    this.centerText,
  });
  
  @override
  State<AnimatedCircularProgress> createState() => _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                value: _animation.value,
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(widget.color),
              ),
            ),
            if (widget.centerText != null)
              Text(
                widget.centerText!,
                style: TextStyle(
                  fontSize: widget.size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
          ],
        );
      },
    );
  }
}
