import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../providers/progress_provider.dart';
import '../providers/lesson_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

// Main Lesson Screen
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentExerciseIndex = 0;
  int _correctAnswers = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Sample exercises for the lesson
  late List<Exercise> _exercises;
  
  @override
  void initState() {
    super.initState();
    _exercises = _getSampleExercises();
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  void _onAnswerSelected(bool isCorrect) {
    if (isCorrect) {
      _correctAnswers++;
      _showFeedback(true);
    } else {
      _showFeedback(false);
    }
    
    // Move to next exercise after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (_currentExerciseIndex < _exercises.length - 1) {
          setState(() {
            _currentExerciseIndex++;
          });
        } else {
          _completLesson();
        }
      }
    });
  }
  
  void _showFeedback(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 64,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                isCorrect ? 'دروستە! 🎉' : 'هەڵەیە 😔',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green[700] : Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isCorrect ? 'بەردەوام بە!' : 'هەوڵ بدەرەوە!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Auto dismiss
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }
  
  void _completLesson() {
    final progressProvider = context.read<ProgressProvider>();
    final xpEarned = (_correctAnswers / _exercises.length * 50).round();
    
    progressProvider.completeLesson(xpEarned);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  size: 48,
                  color: Colors.amber[700],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'وانەکە تەواو بوو!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'وەڵامی دروست: $_correctAnswers/${_exercises.length}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+$xpEarned XP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to home
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'بەردەوامبوون',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _playAudio(String? audioPath) async {
    if (audioPath == null) return;
    try {
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentExercise = _exercises[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / _exercises.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('وانەی یەکەم - پێشوازیەکان'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentExerciseIndex + 1}/${_exercises.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary600),
          ),
          
          // Exercise content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildExercise(currentExercise),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExercise(Exercise exercise) {
    switch (exercise.type) {
      case ExerciseType.multipleChoice:
        return _buildMultipleChoice(exercise);
      case ExerciseType.fillInBlank:
        return _buildFillInBlank(exercise);
      case ExerciseType.translation:
        return _buildTranslation(exercise);
      case ExerciseType.listening:
        return _buildListening(exercise);
    }
  }
  
  Widget _buildMultipleChoice(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'وەڵامی دروست هەڵبژێرە',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary600,
          ),
        ),
        const SizedBox(height: 24),
        
        // Question with audio
        Row(
          children: [
            Expanded(
              child: Text(
                exercise.question,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (exercise.audioPath != null)
              IconButton(
                onPressed: () => _playAudio(exercise.audioPath),
                icon: const Icon(Icons.volume_up_rounded),
                iconSize: 32,
                color: AppColors.primary600,
              ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Options
        ...exercise.options!.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOptionButton(
              entry.value,
              () => _onAnswerSelected(entry.key == exercise.correctAnswerIndex),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildFillInBlank(Exercise exercise) {
    final controller = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'بۆشاییەکە پڕبکەرەوە',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary600,
          ),
        ),
        const SizedBox(height: 24),
        
        Text(
          exercise.question,
          style: const TextStyle(
            fontSize: 20,
            height: 1.6,
          ),
        ),
        
        const SizedBox(height: 32),
        
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'وەڵامەکەت بنووسە...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              final isCorrect = controller.text.trim().toLowerCase() == 
                  exercise.correctAnswer?.toLowerCase();
              _onAnswerSelected(isCorrect);
            },
            child: const Text(
              'پشتڕاستکردنەوە',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTranslation(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'وەرگێڕە بۆ کوردی',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary600,
          ),
        ),
        const SizedBox(height: 24),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary600.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary600.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  exercise.question,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (exercise.audioPath != null)
                IconButton(
                  onPressed: () => _playAudio(exercise.audioPath),
                  icon: const Icon(Icons.volume_up_rounded),
                  iconSize: 28,
                  color: AppColors.primary600,
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Options
        ...exercise.options!.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOptionButton(
              entry.value,
              () => _onAnswerSelected(entry.key == exercise.correctAnswerIndex),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildListening(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'گوێبگرە و وەڵام بدەرەوە',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary600,
          ),
        ),
        const SizedBox(height: 32),
        
        // Audio player button
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary600.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _playAudio(exercise.audioPath),
              icon: const Icon(Icons.volume_up_rounded),
              iconSize: 56,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 48),
        
        // Options
        ...exercise.options!.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOptionButton(
              entry.value,
              () => _onAnswerSelected(entry.key == exercise.correctAnswerIndex),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildOptionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          side: BorderSide(color: Colors.grey[300]!, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
  
  List<Exercise> _getSampleExercises() {
    return [
      Exercise(
        type: ExerciseType.multipleChoice,
        question: 'Hello',
        audioPath: 'audio/pronunciation/hello.mp3',
        options: ['سڵاو', 'سوپاس', 'خواحافیز', 'ببورە'],
        correctAnswerIndex: 0,
      ),
      Exercise(
        type: ExerciseType.translation,
        question: 'Good morning',
        audioPath: 'audio/pronunciation/good_morning.mp3',
        options: ['بەیانی باش', 'شەو باش', 'نیوەڕۆ باش', 'ئێوارە باش'],
        correctAnswerIndex: 0,
      ),
      Exercise(
        type: ExerciseType.fillInBlank,
        question: 'My _____ is Ahmed. (ناوم ئەحمەدە)',
        correctAnswer: 'name',
      ),
      Exercise(
        type: ExerciseType.multipleChoice,
        question: 'Thank you',
        audioPath: 'audio/pronunciation/thank_you.mp3',
        options: ['سوپاس', 'سڵاو', 'خواحافیز', 'بەخێربێیت'],
        correctAnswerIndex: 0,
      ),
      Exercise(
        type: ExerciseType.listening,
        question: 'چی گوێت لێبوو؟',
        audioPath: 'audio/pronunciation/goodbye.mp3',
        options: ['Goodbye', 'Hello', 'Please', 'Sorry'],
        correctAnswerIndex: 0,
      ),
    ];
  }
}

// Exercise model
enum ExerciseType {
  multipleChoice,
  fillInBlank,
  translation,
  listening,
}

class Exercise {
  final ExerciseType type;
  final String question;
  final String? audioPath;
  final List<String>? options;
  final int? correctAnswerIndex;
  final String? correctAnswer;
  
  Exercise({
    required this.type,
    required this.question,
    this.audioPath,
    this.options,
    this.correctAnswerIndex,
    this.correctAnswer,
  });
}