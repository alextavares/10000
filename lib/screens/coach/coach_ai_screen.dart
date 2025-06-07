import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/screens/loading_screen.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/logger.dart';

/// Screen for the AI coach functionality.
class CoachAIScreen extends StatefulWidget {
  /// Constructor for CoachAIScreen.
  const CoachAIScreen({super.key});

  @override
  State<CoachAIScreen> createState() => _CoachAIScreenState();
}

class _CoachAIScreenState extends State<CoachAIScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Habit> _habits = [];
  String? _errorMessage;
  String? _weeklySummary;
  String? _habitPlan;
  bool _isGeneratingPlan = false;
  bool _isGeneratingSummary = false;
  
  // For chat functionality
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isSendingMessage = false;
  
  // For tab controller
  late TabController _tabController;
  
  // For goal setting
  final TextEditingController _goalController = TextEditingController();
  final List<String> _selectedPreferences = [];
  final List<String> _availablePreferences = [
    'Morning routine',
    'Evening routine',
    'Fitness',
    'Nutrition',
    'Mindfulness',
    'Productivity',
    'Learning',
    'Social',
    'Sleep',
    'Hydration',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _goalController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Loads the user's habits and generates the weekly summary.
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load habits
      final habits = await context.habitService.getHabits();
      
      setState(() {
        _habits = habits;
        _isLoading = false;
      });
      
      // Generate weekly summary if we have habits
      if (habits.isNotEmpty) {
        _generateWeeklySummary();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data. Please try again.';
        _isLoading = false;
      });
      Logger.error('Error loading data: $e');
    }
  }

  /// Generates a weekly summary of the user's habits.
  Future<void> _generateWeeklySummary() async {
    if (_habits.isEmpty) return;

    setState(() {
      _isGeneratingSummary = true;
    });

    try {
      // Calculate the start and end of the current week
      final now = DateTime.now();
      final weekStart = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: now.weekday - 1),
      );
      final weekEnd = weekStart.add(const Duration(days: 6));

      // Generate the summary
      final summary = await context.aiService.generateWeeklySummary(
        _habits,
        weekStart,
        weekEnd,
      );

      setState(() {
        _weeklySummary = summary;
        _isGeneratingSummary = false;
      });
    } catch (e) {
      setState(() {
        _weeklySummary = 'Unable to generate weekly summary at this time.';
        _isGeneratingSummary = false;
      });
      Logger.error('Error generating weekly summary: $e');
    }
  }

  /// Generates a personalized habit plan based on the user's goal.
  Future<void> _generateHabitPlan() async {
    final goal = _goalController.text.trim();
    if (goal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a goal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingPlan = true;
    });

    try {
      final plan = await context.aiService.generateHabitPlan(
        goal,
        _selectedPreferences,
      );

      setState(() {
        _habitPlan = plan;
        _isGeneratingPlan = false;
      });
    } catch (e) {
      setState(() {
        _habitPlan = 'Unable to generate habit plan at this time.';
        _isGeneratingPlan = false;
      });
      Logger.error('Error generating habit plan: $e');
    }
  }

  /// Sends a message to the AI coach.
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isSendingMessage = true;
    });

    _messageController.clear();

    try {
      // In a real app, this would call a method in AIService to get a response
      // For now, we'll simulate a response after a short delay
      await Future.delayed(const Duration(seconds: 1));
      
      final response = "I'm your AI coach! I'm here to help you build and maintain healthy habits. "
          "You can ask me for advice, motivation, or insights about your habits. "
          "What would you like to know today?";

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isSendingMessage = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "I'm sorry, I couldn't process your message at this time. Please try again later.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isSendingMessage = false;
      });
      Logger.error('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreenWithMessage(
        message: 'Loading your AI coach...',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        backgroundColor: AppTheme.aiPrimaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Chat', icon: Icon(Icons.chat)),
            Tab(text: 'Insights', icon: Icon(Icons.insights)),
            Tab(text: 'Goals', icon: Icon(Icons.flag)),
          ],
        ),
      ),
      body: _errorMessage != null
          ? _buildErrorView()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChatTab(),
                _buildInsightsTab(),
                _buildGoalsTab(),
              ],
            ),
    );
  }

  /// Builds the error view.
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.aiPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Builds the chat tab.
  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildChatWelcome()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  reverse: false,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildChatBubble(message);
                  },
                ),
        ),
        if (_isSendingMessage)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 16),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.aiPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI is thinking...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.subtitleColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask your AI coach...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: _sendMessage,
                backgroundColor: AppTheme.aiPrimaryColor,
                mini: true,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the welcome message for the chat tab.
  Widget _buildChatWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_alt,
            size: 64,
            color: AppTheme.aiPrimaryColor.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to your AI Coach!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Ask me anything about your habits, goals, or progress. '
              'I can provide personalized advice, motivation, and insights.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _messages.add(ChatMessage(
                  text: "Hello! I'm looking for some advice on building better habits.",
                  isUser: true,
                  timestamp: DateTime.now(),
                ));
                
                // Simulate AI response
                _isSendingMessage = true;
              });
              
              // Delayed response
              Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  _messages.add(ChatMessage(
                    text: "Hi there! I'd be happy to help you build better habits. "
                        "The key to successful habit formation is consistency and starting small. "
                        "What specific area would you like to improve? For example, fitness, productivity, or mindfulness?",
                    isUser: false,
                    timestamp: DateTime.now(),
                  ));
                  _isSendingMessage = false;
                });
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.aiPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Start a conversation'),
          ),
        ],
      ),
    );
  }

  /// Builds a chat bubble for a message.
  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: AppTheme.aiPrimaryColor,
              child: const Icon(
                Icons.psychology_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.aiPrimaryColor.withValues(alpha: 0.1)
                    : AppTheme.aiPrimaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the insights tab.
  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly summary section
          Text(
            'Weekly Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: _isGeneratingSummary
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.insights,
                            color: AppTheme.aiPrimaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _weeklySummary ??
                                  "You don't have any habits tracked yet. "
                                  "Start tracking habits to get a weekly summary!",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textColor,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_habits.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _generateWeeklySummary,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Summary'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.aiPrimaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 24),

          // Habit suggestions section
          Text(
            'Habit Suggestions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.aiPrimaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Based on your current habits, here are some suggestions to enhance your routine:",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Sample suggestions - in a real app, these would come from the AI
                ...[
                  "Drink a glass of water before each meal to improve hydration",
                  "Take a 5-minute stretching break every hour of work",
                  "Practice deep breathing for 2 minutes before bed",
                  "Write down three things you're grateful for each morning",
                ].map((suggestion) => _buildSuggestionItem(suggestion)),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to add habit screen with suggestion
                      Navigator.pushNamed(context, '/add-habit');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Suggested Habit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.aiPrimaryColor,
                      foregroundColor: Colors.white,
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

  /// Builds a suggestion item.
  Widget _buildSuggestionItem(String suggestion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppTheme.aiPrimaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the goals tab.
  Widget _buildGoalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set a New Goal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _goalController,
                  decoration: InputDecoration(
                    labelText: 'What is your goal?',
                    hintText: 'e.g., Improve fitness, Learn a new skill',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select your preferences:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availablePreferences.map((preference) {
                    final isSelected = _selectedPreferences.contains(preference);
                    return FilterChip(
                      label: Text(preference),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPreferences.add(preference);
                          } else {
                            _selectedPreferences.remove(preference);
                          }
                        });
                      },
                      backgroundColor: AppTheme.surfaceColor,
                      selectedColor: AppTheme.aiPrimaryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.aiPrimaryColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _generateHabitPlan,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Habit Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.aiPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_habitPlan != null || _isGeneratingPlan) ...[
            Text(
              'Your Personalized Habit Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: _isGeneratingPlan
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Generating your personalized habit plan...'),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: AppTheme.aiPrimaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _habitPlan!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textColor,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to add habit screen
                              Navigator.pushNamed(context, '/add-habit');
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add These Habits'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.aiPrimaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Represents a chat message.
class ChatMessage {
  /// The text content of the message.
  final String text;
  
  /// Whether the message is from the user.
  final bool isUser;
  
  /// The timestamp of the message.
  final DateTime timestamp;

  /// Constructor for ChatMessage.
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
