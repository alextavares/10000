import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  int _selectedTabIndex = 0; // 0: Cronômetro, 1: Timer, 2: Intervalos
  
  // Cronômetro
  Timer? _stopwatchTimer;
  int _stopwatchMilliseconds = 0;
  bool _isStopwatchRunning = false;
  final List<String> _lapTimes = [];
  int _lastLapTime = 0;
  
  // Timer
  Timer? _countdownTimer;
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;
  int _totalCountdownSeconds = 0;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  bool _isTimerConfigured = false;
  
  // Intervalos
  // bool _isIntervalRunning = false; // Descomentado quando implementar
  
  // Configurações
  bool _vibrationEnabled = true;
  // bool _soundEnabled = true; // Descomentado quando implementar sons
  
  // Atividade selecionada
  String? _selectedActivity;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatStopwatchTime(int milliseconds) {
    int seconds = (milliseconds ~/ 1000) % 60;
    int minutes = (milliseconds ~/ 60000) % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTimerTime(int seconds) {
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _startStopwatch() {
    setState(() {
      _isStopwatchRunning = true;
    });
    
    _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _stopwatchMilliseconds += 10;
      });
    });
  }

  void _pauseStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() {
      _isStopwatchRunning = false;
    });
  }

  void _resetStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() {
      _stopwatchMilliseconds = 0;
      _isStopwatchRunning = false;
      _lapTimes.clear();
      _lastLapTime = 0;
    });
  }

  void _recordLap() {
    if (_isStopwatchRunning && _stopwatchMilliseconds > 0) {
      final lapTime = _stopwatchMilliseconds - _lastLapTime;
      setState(() {
        _lapTimes.add(_formatStopwatchTime(lapTime));
        _lastLapTime = _stopwatchMilliseconds;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _showTimerConfiguration() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildTimerConfigurationSheet(),
    );
  }

  Widget _buildTimerConfigurationSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Configurar Timer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimePickerColumn(
                    value: _selectedHours,
                    label: 'Horas',
                    max: 23,
                    onChanged: (value) {
                      setModalState(() => _selectedHours = value);
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    ':',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildTimePickerColumn(
                    value: _selectedMinutes,
                    label: 'Minutos',
                    max: 59,
                    onChanged: (value) {
                      setModalState(() => _selectedMinutes = value);
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    ':',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildTimePickerColumn(
                    value: _selectedSeconds,
                    label: 'Segundos',
                    max: 59,
                    onChanged: (value) {
                      setModalState(() => _selectedSeconds = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: (_selectedHours == 0 && _selectedMinutes == 0 && _selectedSeconds == 0)
                    ? null
                    : () {
                        setState(() {
                          _totalCountdownSeconds = (_selectedHours * 3600) + 
                                                  (_selectedMinutes * 60) + 
                                                  _selectedSeconds;
                          _remainingSeconds = _totalCountdownSeconds;
                          _isTimerConfigured = true;
                        });
                        Navigator.pop(context);
                        _startTimer();
                      },
                child: const Text(
                  'INICIAR TIMER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimePickerColumn({
    required int value,
    required String label,
    required int max,
    required Function(int) onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[700]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => onChanged((value + 1) % (max + 1)),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_drop_up, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: () => onChanged(value > 0 ? value - 1 : max),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _startTimer() {
    if (_totalCountdownSeconds == 0) return;
    
    setState(() {
      _isTimerRunning = true;
      _isTimerPaused = false;
    });
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeTimer();
        }
      });
    });
  }

  void _pauseTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerPaused = true;
    });
  }

  void _resetTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _totalCountdownSeconds = 0;
      _isTimerRunning = false;
      _isTimerPaused = false;
      _isTimerConfigured = false;
    });
  }

  void _completeTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _isTimerPaused = false;
    });
    
    if (_vibrationEnabled) {
      HapticFeedback.vibrate();
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Timer Concluído!',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'O tempo acabou.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFE91E63)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      child: Column(
        children: [
          // Conteúdo principal
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Círculo do timer
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.5),
                      width: 16,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _selectedTabIndex == 0
                          ? _formatStopwatchTime(_stopwatchMilliseconds)
                          : (_isTimerConfigured || _isTimerRunning || _isTimerPaused)
                              ? _formatTimerTime(_remainingSeconds)
                              : '00:00',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                // Botão principal
                _buildMainButton(),
              ],
            ),
          ),
          // Abas customizadas
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildTab(0, Icons.timer_outlined, 'Cronômetro'),
                _buildTab(1, Icons.hourglass_empty_rounded, 'Timer'),
                _buildTab(2, Icons.loop_rounded, 'Intervalos'),
              ],
            ),
          ),
          // Seção de histórico
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                if (_selectedTabIndex == 0 && _lapTimes.isNotEmpty) ...[
                  Text(
                    'Voltas registradas',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _lapTimes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Volta ${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _lapTimes[index],
                                style: TextStyle(
                                  color: const Color(0xFFE91E63),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Text(
                    'Sem registros recentes',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(color: Colors.grey, height: 1),
                const SizedBox(height: 16),
                Text(
                  _selectedActivity ?? 'Nenhuma atividade selecionada',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    if (_selectedTabIndex == 0) {
      // Cronômetro
      if (!_isStopwatchRunning && _stopwatchMilliseconds == 0) {
        return _buildActionButton(
          onPressed: _startStopwatch,
          icon: Icons.play_arrow,
          label: 'INICIAR',
        );
      } else if (_isStopwatchRunning) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              onPressed: _pauseStopwatch,
              icon: Icons.pause,
              label: 'PAUSAR',
            ),
            const SizedBox(width: 16),
            _buildSecondaryButton(
              onPressed: _recordLap,
              icon: Icons.flag,
              label: 'VOLTA',
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              onPressed: _startStopwatch,
              icon: Icons.play_arrow,
              label: 'CONTINUAR',
            ),
            const SizedBox(width: 16),
            _buildSecondaryButton(
              onPressed: _resetStopwatch,
              icon: Icons.refresh,
              label: 'RESETAR',
            ),
          ],
        );
      }
    } else if (_selectedTabIndex == 1) {
      // Timer
      if (!_isTimerConfigured && !_isTimerRunning && !_isTimerPaused) {
        return _buildActionButton(
          onPressed: _showTimerConfiguration,
          icon: Icons.play_arrow,
          label: 'INICIAR',
        );
      } else if (_isTimerRunning && !_isTimerPaused) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              onPressed: _pauseTimer,
              icon: Icons.pause,
              label: 'PAUSAR',
            ),
            const SizedBox(width: 16),
            _buildSecondaryButton(
              onPressed: _resetTimer,
              icon: Icons.stop,
              label: 'PARAR',
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              onPressed: _startTimer,
              icon: Icons.play_arrow,
              label: 'CONTINUAR',
            ),
            const SizedBox(width: 16),
            _buildSecondaryButton(
              onPressed: _resetTimer,
              icon: Icons.refresh,
              label: 'RESETAR',
            ),
          ],
        );
      }
    } else {
      // Intervalos
      return _buildActionButton(
        onPressed: () {
          // TODO: Implementar intervalos
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recurso Premium - Em breve!'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        icon: Icons.play_arrow,
        label: 'INICIAR',
      );
    }
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE91E63),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: Icon(icon, color: Colors.white, size: 24),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE91E63),
        side: const BorderSide(color: Color(0xFFE91E63), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final bool isSelected = _selectedTabIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFFE91E63).withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: const Color(0xFFE91E63), width: 2)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? const Color(0xFFE91E63) 
                    : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? const Color(0xFFE91E63) 
                      : Colors.grey[600],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
