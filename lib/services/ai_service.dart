import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/utils/logger.dart';

/// Service for handling AI-related functionality.
class AIService {
  /// API key for Google Generative AI.
  final String apiKey;

  /// Model to use for generating content.
  final String model;

  /// Constructor for AIService.
  AIService({
    required this.apiKey,
    this.model = 'gemini-pro',
  });

  /// Generates habit suggestions based on the given category.
  Future<List<String>> generateHabitSuggestions(String category) async {
    try {
      final model = GenerativeModel(
        model: this.model,
        apiKey: apiKey,
      );

      final prompt = '''
Generate 5 specific habit suggestions for the category: $category.
Each suggestion should be actionable, measurable, and realistic.
Format each suggestion as a single sentence without numbering.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null) {
        return _getFallbackSuggestions(category);
      }

      // Parse the response into individual suggestions
      final suggestions = response.text!
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
          .toList();

      return suggestions.take(5).toList();
    } catch (e) {
      Logger.error('Error generating habit suggestions: $e');
      return _getFallbackSuggestions(category);
    }
  }

  /// Provides fallback suggestions when the API is not available
  List<String> _getFallbackSuggestions(String category) {
    final Map<String, List<String>> fallbackSuggestions = {
      'Health': [
        'Drink 8 glasses of water daily',
        'Take a 30-minute walk every day',
        'Practice meditation for 10 minutes in the morning',
        'Stretch for 5 minutes before bed',
        'Eat at least 3 servings of vegetables daily',
      ],
      'Fitness': [
        'Do 20 push-ups daily',
        'Run for 20 minutes three times a week',
        'Take 10,000 steps every day',
        'Practice yoga for 15 minutes daily',
        'Do a 30-second plank each morning',
      ],
      'Productivity': [
        'Complete your most important task before noon',
        'Take a 5-minute break every hour of focused work',
        "Plan tomorrow's tasks before bed",
        'Keep a daily journal',
        'Limit social media to 30 minutes daily',
      ],
      'Learning': [
        'Read 10 pages of a book every day',
        'Learn 3 new vocabulary words daily',
        'Practice a new skill for 20 minutes daily',
        'Watch one educational video per day',
        'Solve one puzzle or brain teaser daily',
      ],
      'Mindfulness': [
        "Practice gratitude by listing 3 things you're thankful for",
        'Meditate for 10 minutes daily',
        'Take 5 deep breaths when you feel stressed',
        'Do one random act of kindness daily',
        'Spend 15 minutes in nature daily',
      ],
    };

    // Return default suggestions if category not found
    return fallbackSuggestions[category] ?? [
      'Drink more water throughout the day',
      'Take a 15-minute walk after meals',
      'Read for 20 minutes before bed',
      'Practice deep breathing for 5 minutes daily',
      'Write down 3 accomplishments at the end of each day',
    ];
  }

  /// Generates insights based on the user's habit completion history.
  Future<String> generateHabitInsights(List<Habit> habits) async {
    try {
      if (habits.isEmpty) {
        return "You haven't tracked any habits yet. Start adding habits to get personalized insights!";
      }

      final model = GenerativeModel(
        model: this.model,
        apiKey: apiKey,
      );

      // Prepare habit data for the prompt
      final habitData = habits.map((habit) {
        final completionRate = habit.getCompletionRate() * 100;
        return '''
Habit: ${habit.title}
Category: ${habit.category}
Frequency: ${habit.frequency.toString().split('.').last}
Current Streak: ${habit.streak} days
Longest Streak: ${habit.longestStreak} days
Completion Rate: ${completionRate.toStringAsFixed(1)}%
''';
      }).join('\n');

      final prompt = '''
Based on the following habit tracking data, provide personalized insights and recommendations:

$habitData

Provide insights on:
1. Patterns in habit completion
2. Areas of strength
3. Areas for improvement
4. Specific, actionable recommendations to improve habit consistency
5. Positive reinforcement for achievements

Keep the response concise, supportive, and actionable. Focus on 2-3 key insights.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      return response.text ?? "Unable to generate insights at this time.";
    } catch (e) {
      Logger.error('Error generating habit insights: $e');
      return "Unable to generate insights at this time. Please try again later.";
    }
  }

  /// Generates a personalized habit plan based on user goals.
  Future<String> generateHabitPlan(String goal, List<String> preferences) async {
    try {
      final model = GenerativeModel(
        model: this.model,
        apiKey: apiKey,
      );

      final preferencesText = preferences.join(', ');
      
      final prompt = '''
Create a personalized habit plan to help achieve the following goal:
"$goal"

User preferences: $preferencesText

The plan should include:
1. 3-5 specific habits that will help achieve this goal
2. Recommended frequency for each habit
3. Tips for successfully implementing each habit
4. How to track progress
5. How to overcome common obstacles

Format the response in a clear, structured way with sections and bullet points where appropriate.
Keep the tone supportive and motivational.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      return response.text ?? "Unable to generate a habit plan at this time.";
    } catch (e) {
      Logger.error('Error generating habit plan: $e');
      return "Unable to generate a habit plan at this time. Please try again later.";
    }
  }

  /// Analyzes the user's habit data and provides a weekly summary.
  Future<String> generateWeeklySummary(List<Habit> habits, DateTime weekStart, DateTime weekEnd) async {
    try {
      if (habits.isEmpty) {
        return "You haven't tracked any habits this week. Start adding habits to get a weekly summary!";
      }

      final model = GenerativeModel(
        model: this.model,
        apiKey: apiKey,
      );

      // Prepare habit data for the prompt
      final habitData = habits.map((habit) {
        // Calculate completion rate for this week only
        int daysCompleted = 0;
        int totalDays = 0;
        
        for (DateTime date = weekStart; date.isBefore(weekEnd.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
          if (habit.completionHistory.containsKey(date)) {
            totalDays++;
            if (habit.completionHistory[date] == true) {
              daysCompleted++;
            }
          }
        }
        
        final weeklyCompletionRate = totalDays > 0 ? (daysCompleted / totalDays) * 100 : 0;
        
        return '''
Habit: ${habit.title}
Category: ${habit.category}
Days Completed This Week: $daysCompleted out of $totalDays
Weekly Completion Rate: ${weeklyCompletionRate.toStringAsFixed(1)}%
Current Streak: ${habit.streak} days
''';
      }).join('\n');

      final prompt = '''
Generate a weekly summary for the user's habits from ${_formatDate(weekStart)} to ${_formatDate(weekEnd)}:

$habitData

Include in your summary:
1. Overall performance for the week
2. Most consistent habits
3. Habits that need more attention
4. Progress compared to previous weeks (if applicable)
5. Encouragement and motivation for the coming week

Keep the tone positive and supportive, even when highlighting areas for improvement.
Format the response in a clear, structured way.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      return response.text ?? "Unable to generate a weekly summary at this time.";
    } catch (e) {
      Logger.error('Error generating weekly summary: $e');
      return "Unable to generate a weekly summary at this time. Please try again later.";
    }
  }

  /// Formats a date as a string.
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
