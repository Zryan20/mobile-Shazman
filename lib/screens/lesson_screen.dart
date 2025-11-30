import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/lesson_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/hearts_provider.dart';
import '../services/lesson_data_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_texts.dart';
import '../widgets/custom_button.dart';
import '../widgets/progress_bar.dart';

class LessonScreen extends StatefulWidget {
  final String? lessonId;
  
  const LessonScreen({super.key, this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentExerciseIndex = 0;
  int _correctAnswers = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;
  
  // Lesson data
  Map<String, dynamic>? _lessonData;
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;
  String? _errorMessage;

bool _isInit = true;

@override
void didChangeDependencies() {
  if (_isInit) {
    _loadLessonData();
    _isInit = false;
  }
  super.didChangeDependencies();
}


  Future<void> _loadLessonData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get lesson ID from widget or arguments
      String? lessonId = widget.lessonId;
      
      if (lessonId == null) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        lessonId = args?['lessonId'] as String?;
      }
      
      // Fallback to first lesson if no ID provided
      lessonId ??= 'a1_s1_l1';
      
      print('📚 Loading lesson: $lessonId');
      
      // Load lesson data from JSON
      final data = await LessonDataService.loadLessonData(lessonId);
      
      if (data == null) {
        throw Exception('Lesson not found: $lessonId');
      }
      
      setState(() {
        _lessonData = data;
        final raw = data['exercises'] as List<dynamic>? ?? [];
        _exercises = raw.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
      
      print('✅ Loaded ${_exercises.length} exercises');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      print('❌ Error loading lesson: $e');
    }
  }

  void _checkAnswer(String answer) {
    if (_isAnswered) return;
    
    final currentExercise = _exercises[_currentExerciseIndex];
    final correctAnswer = currentExercise['correctAnswer'] as String;
    final isCorrect = answer.toLowerCase().trim() == correctAnswer.toLowerCase().trim();
    
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      
      if (isCorrect) {
        _correctAnswers++;
      } else {
        // Lose a heart on wrong answer
        context.read<HeartsProvider>().loseHeart();
      }
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _isAnswered = false;
        _selectedAnswer = null;
      });
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() {
    final score = (_correctAnswers / _exercises.length * 100).round();
    final xpEarned = score >= 80 ? 15 : (score >= 60 ? 10 : 5);
    
    // Get lesson ID
    final lessonId = _lessonData?['id'] as String? ?? 'a1_s1_l1';
    
    // Update progress
    context.read<ProgressProvider>().completeLesson(xpEarned, lessonId: lessonId);
    context.read<LessonProvider>().completeCurrentLesson();
    
    // Show completion dialog
    _showCompletionDialog(score, xpEarned);
  }

  void _showCompletionDialog(int score, int xpEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              score >= 80
                  ? Icons.emoji_events_rounded
                  : Icons.check_circle_rounded,
              color: score >= 80 ? AppColors.xpGold : AppColors.success,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              score >= 80 ? AppTexts.excellent : AppTexts.wellDone,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppTexts.lessonCompleted,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Score
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary600.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Score',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_correctAnswers/${_exercises.length} correct',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // XP earned
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppColors.xpGold,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '+$xpEarned XP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.xpGold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: AppTexts.continueButton,
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to learning path
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.areYouSure),
        content: const Text(AppTexts.confirmExitLesson),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit lesson
            },
            child: Text(
              AppTexts.yes,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Error state
    if (_errorMessage != null || _exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'No exercises available',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Go Back',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }
    
    final currentExercise = _exercises[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / _exercises.length;
    final correctAnswer = currentExercise['correctAnswer'] as String;
    final isCorrect = _isAnswered && 
        _selectedAnswer?.toLowerCase().trim() == correctAnswer.toLowerCase().trim();

    return WillPopScope(
      onWillPop: () async {
        _showExitDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _showExitDialog,
          ),
          title: Text('${_lessonData?['titleKurdish'] ?? 'Lesson'} ${_currentExerciseIndex + 1}/${_exercises.length}'),
          actions: [
    Consumer<HeartsProvider>(
      builder: (context, hearts, child) {
        return Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.red,
              size: 22,
            ),
            SizedBox(width: 4),
            Text(
              '${hearts.currentHearts}/${hearts.maxHearts}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 12),
          ],
        );
      },
    ),
  ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: CustomProgressBar(
              progress: progress,
              height: 4,
              progressColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary600.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getExerciseTypeName(currentExercise['type'] as String),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Question (English)
                      Text(
                        currentExercise['question'] as String,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Question (Kurdish)
                      if (currentExercise['questionKurdish'] != null)
                        Text(
                          currentExercise['questionKurdish'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Character placeholder
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary600.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            size: 60,
                            color: AppColors.primary600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Hint for fill_blank exercises
                      if (currentExercise['type'] == 'fill_blank' && 
                          currentExercise['hint'] != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Hint: ${currentExercise['hint']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Answer options (for multiple choice)
                      if (currentExercise['options'] != null)
                        ...(currentExercise['options'] as List<dynamic>).map((option) {
                          final optionStr = option as String;
                          final isSelected = _selectedAnswer == optionStr;
                          final isCorrectOption = optionStr.toLowerCase().trim() == 
                              correctAnswer.toLowerCase().trim();
                          
                          Color? backgroundColor;
                          Color? borderColor;
                          Color? textColor;
                          
                          if (_isAnswered) {
                            if (isSelected) {
                              if (isCorrect) {
                                backgroundColor = AppColors.successLight;
                                borderColor = AppColors.success;
                                textColor = AppColors.success;
                              } else {
                                backgroundColor = AppColors.errorLight;
                                borderColor = AppColors.error;
                                textColor = AppColors.error;
                              }
                            } else if (isCorrectOption) {
                              backgroundColor = AppColors.successLight;
                              borderColor = AppColors.success;
                              textColor = AppColors.success;
                            }
                          } else if (isSelected) {
                            backgroundColor = AppColors.primary600.withOpacity(0.1);
                            borderColor = AppColors.primary600;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: backgroundColor ?? Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: _isAnswered ? null : () => _checkAnswer(optionStr),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: borderColor ?? AppColors.border,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          optionStr,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: textColor ?? AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (_isAnswered && (isSelected || isCorrectOption))
                                        Icon(
                                          (isSelected && isCorrect) || isCorrectOption
                                              ? Icons.check_circle_rounded
                                              : Icons.cancel_rounded,
                                          color: (isSelected && isCorrect) || isCorrectOption
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      
                      // Text input for fill_blank and translation
                      if (currentExercise['type'] == 'fill_blank' || 
                          currentExercise['type'] == 'translation') ...[
                        TextField(
                          enabled: !_isAnswered,
                          onSubmitted: (value) {
                            if (!_isAnswered && value.isNotEmpty) {
                              _checkAnswer(value);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Type your answer...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: _isAnswered ? Colors.grey[100] : Colors.white,
                          ),
                          style: const TextStyle(fontSize: 16),
                          onChanged: (value) {
                            setState(() {
                              _selectedAnswer = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (!_isAnswered && _selectedAnswer != null && _selectedAnswer!.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              text: 'Check Answer',
                              onPressed: () => _checkAnswer(_selectedAnswer!),
                            ),
                          ),
                      ],
                      
                      // Feedback message
                      if (_isAnswered) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? AppColors.successLight
                                : AppColors.errorLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCorrect
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: isCorrect
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isCorrect
                                      ? AppTexts.correct
                                      : '${AppTexts.incorrect}. The correct answer is "$correctAnswer"',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isCorrect
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Bottom button
              if (_isAnswered)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: _currentExerciseIndex < _exercises.length - 1
                            ? AppTexts.next
                            : AppTexts.finish,
                        onPressed: _nextExercise,
                        icon: _currentExerciseIndex < _exercises.length - 1
                            ? Icons.arrow_forward_rounded
                            : Icons.check_rounded,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getExerciseTypeName(String type) {
    switch (type) {
      case 'multiple_choice':
        return AppTexts.multipleChoice;
      case 'fill_blank':
        return AppTexts.fillInTheBlank;
      case 'matching':
        return AppTexts.matching;
      case 'listening':
        return AppTexts.listening;
      case 'speaking':
        return AppTexts.speaking;
      case 'translation':
        return 'Translation';
      default:
        return type;
    }
  }
}