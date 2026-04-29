import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/hearts_provider.dart';
import '../services/audio_service.dart';
import '../services/lesson_data_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_texts.dart';
import '../widgets/clickable_word.dart';
import '../widgets/custom_button.dart';

// Main Lesson Screen with Teaching Phase
class LessonScreen extends StatefulWidget {
  final String? lessonId;

  const LessonScreen({super.key, this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  // Lesson phases
  LessonPhase _currentPhase = LessonPhase.introduction;

  // Introduction phase state
  int _currentIntroPage = 0;

  // Exercise phase state
  int _currentExerciseIndex = 0;
  int _correctAnswers = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;

  // Lesson data
  Map<String, dynamic>? _lessonData;
  List<Map<String, dynamic>> _vocabulary = [];
  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _grammarNotes = [];
  List<Map<String, dynamic>> _culturalNotes = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Sentence builder state
  List<String> _builtSentence = [];
  List<String> _shuffledBank = [];

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
      String? lessonId = widget.lessonId;

      if (lessonId == null) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        lessonId = args?['lessonId'] as String?;
      }

      lessonId ??= 'a1_s1_l1';

      final data = await LessonDataService.loadLessonData(lessonId);

      if (data == null) {
        throw Exception('Lesson not found: $lessonId');
      }

      setState(() {
        _lessonData = data;
        _vocabulary = (data['vocabulary'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];
        _exercises = (data['exercises'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];
        _grammarNotes = (data['grammarNotes'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];
        _culturalNotes = (data['culturalNotes'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _nextIntroPage() {
    if (_currentPhase == LessonPhase.introduction) {
      if (_currentIntroPage < _vocabulary.length - 1) {
        setState(() {
          _currentIntroPage++;
        });
      } else if (_grammarNotes.isNotEmpty) {
        setState(() {
          _currentPhase = LessonPhase.grammarNotes;
          _currentIntroPage = 0; // Reuse for grammar index
        });
      } else if (_culturalNotes.isNotEmpty) {
        setState(() {
          _currentPhase = LessonPhase.culturalNotes;
          _currentIntroPage = 0; // Reuse for cultural index
        });
      } else {
        _startExercises();
      }
    } else if (_currentPhase == LessonPhase.grammarNotes) {
      if (_currentIntroPage < _grammarNotes.length - 1) {
        setState(() {
          _currentIntroPage++;
        });
      } else if (_culturalNotes.isNotEmpty) {
        setState(() {
          _currentPhase = LessonPhase.culturalNotes;
          _currentIntroPage = 0;
        });
      } else {
        _startExercises();
      }
    } else if (_currentPhase == LessonPhase.culturalNotes) {
      if (_currentIntroPage < _culturalNotes.length - 1) {
        setState(() {
          _currentIntroPage++;
        });
      } else {
        _startExercises();
      }
    }
  }

  void _startExercises() {
    setState(() {
      _currentPhase = LessonPhase.exercises;
    });
    _initExercise(0);
  }

  void _previousIntroPage() {
    if (_currentPhase == LessonPhase.introduction) {
      if (_currentIntroPage > 0) {
        setState(() {
          _currentIntroPage--;
        });
      }
    } else if (_currentPhase == LessonPhase.grammarNotes) {
      if (_currentIntroPage > 0) {
        setState(() {
          _currentIntroPage--;
        });
      } else {
        setState(() {
          _currentPhase = LessonPhase.introduction;
          _currentIntroPage = _vocabulary.length - 1;
        });
      }
    } else if (_currentPhase == LessonPhase.culturalNotes) {
      if (_currentIntroPage > 0) {
        setState(() {
          _currentIntroPage--;
        });
      } else if (_grammarNotes.isNotEmpty) {
        setState(() {
          _currentPhase = LessonPhase.grammarNotes;
          _currentIntroPage = _grammarNotes.length - 1;
        });
      } else {
        setState(() {
          _currentPhase = LessonPhase.introduction;
          _currentIntroPage = _vocabulary.length - 1;
        });
      }
    }
  }

  void _skipToExercises() {
    setState(() {
      _currentPhase = LessonPhase.exercises;
    });
  }

  void _selectAnswer(String answer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _checkAnswer() {
    if (_isAnswered || _selectedAnswer == null) return;

    final currentExercise = _exercises[_currentExerciseIndex];
    final correctAnswer = currentExercise['correctAnswer'] as String;
    final isCorrect = _selectedAnswer!.toLowerCase().trim() ==
        correctAnswer.toLowerCase().trim();

    setState(() {
      _isAnswered = true;

      if (isCorrect) {
        _correctAnswers++;
      } else {
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
      _initExercise(_currentExerciseIndex);
    } else {
      _finishLesson();
    }
  }

  void _initExercise(int index) {
    if (index >= _exercises.length) return;
    
    final exercise = _exercises[index];
    
    // Handle Sentence Builder initialization
    if (exercise['type'] == 'sentence_builder') {
      final List<String> bank = List<String>.from(exercise['options'] ?? []);
      setState(() {
        _builtSentence = [];
        _shuffledBank = bank..shuffle();
      });
    }

    _checkAutoPlay();
  }

  void _handleWordTap(String word, bool fromBank) {
    if (_isAnswered) return;
    
    setState(() {
      if (fromBank) {
        _shuffledBank.remove(word);
        _builtSentence.add(word);
      } else {
        _builtSentence.remove(word);
        _shuffledBank.add(word);
      }
    });
  }

  void _checkSentence() {
    if (_builtSentence.isEmpty || _isAnswered) return;
    
    final fullSentence = _builtSentence.join(' ');
    _selectAnswer(fullSentence);
  }

  void _checkAutoPlay() {
    if (_currentPhase == LessonPhase.exercises && _exercises.isNotEmpty) {
      final currentExercise = _exercises[_currentExerciseIndex];
      if (currentExercise['type'] == 'listening') {
        // Delay slightly to allow the UI to transition
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _currentPhase == LessonPhase.exercises) {
            final textToSpeak = currentExercise['textToSpeak'] ?? 
                              currentExercise['correctAnswer'] ?? 
                              currentExercise['question'];
            AudioService().playPronunciation(
              textToSpeak as String, 
              audioPath: currentExercise['audioPath'] as String?
            );
          }
        });
      }
    }
  }

  void _finishLesson() {
    final score = (_correctAnswers / _exercises.length * 100).round();
    final xpEarned = score >= 80 ? 15 : (score >= 60 ? 10 : 5);

    final lessonId = _lessonData?['id'] as String? ?? 'a1_s1_l1';

    context
        .read<ProgressProvider>()
        .completeLesson(xpEarned, lessonId: lessonId);
    context.read<LessonProvider>().completeCurrentLesson();

    _showCompletionDialog(score, xpEarned);
  }

  void _showCompletionDialog(int score, int xpEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppTexts.lessonCompleted,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary600.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('نمرە',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    '$score%',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_correctAnswers/${_exercises.length} ڕاست',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.xpGold, size: 24),
                const SizedBox(width: 8),
                Text(
                  '+$xpEarned XP',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.xpGold),
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
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('باردەکرێت...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _vocabulary.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('هەڵە')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'No content available',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                  text: 'بگەڕێوە', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _showExitDialog,
          ),
          actions: [
            if (_currentPhase != LessonPhase.exercises)
              TextButton(
                onPressed: _skipToExercises,
                child: const Text('تێپەڕاندن', style: TextStyle(fontSize: 14)),
              ),
            Consumer<HeartsProvider>(
              builder: (context, hearts, child) {
                return Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      '${hearts.currentHearts}/${hearts.maxHearts}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                  ],
                );
              },
            ),
          ],
        ),
        body: _currentPhase == LessonPhase.exercises
            ? _buildExercisePhase()
            : _buildIntroductionPhase(),
      ),
    );
  }

  Widget _buildIntroductionPhase() {
    Widget content;
    double progress;

    if (_currentPhase == LessonPhase.introduction) {
      final vocab = _vocabulary[_currentIntroPage];
      progress = (_currentIntroPage + 1) / (_vocabulary.length + _grammarNotes.length + _culturalNotes.length);
      content = VocabularyIntroCard(
        englishWord: vocab['english'] as String,
        kurdishTranslation: vocab['kurdish'] as String,
        audioPath: vocab['audioPath'] as String?,
        exampleSentence: vocab['exampleSentence'] as String?,
        exampleTranslation: vocab['exampleTranslation'] as String?,
        imageUrl: vocab['imageUrl'] as String?,
        notes: vocab['notes'] as String?,
        notesKurdish: vocab['notesKurdish'] as String?,
      );
    } else if (_currentPhase == LessonPhase.grammarNotes) {
      final note = _grammarNotes[_currentIntroPage];
      progress = (_vocabulary.length + _currentIntroPage + 1) / 
                 (_vocabulary.length + _grammarNotes.length + _culturalNotes.length);
      content = LessonNoteCard(
        title: note['title'] as String,
        titleKurdish: note['titleKurdish'] as String?,
        content: note['content'] as String,
        contentKurdish: note['contentKurdish'] as String?,
        examples: note['examples'] != null ? List<String>.from(note['examples']) : null,
        icon: Icons.menu_book_rounded,
        color: AppColors.primary600,
      );
    } else {
      final note = _culturalNotes[_currentIntroPage];
      progress = (_vocabulary.length + _grammarNotes.length + _currentIntroPage + 1) / 
                 (_vocabulary.length + _grammarNotes.length + _culturalNotes.length);
      content = LessonNoteCard(
        title: note['title'] as String,
        titleKurdish: note['titleKurdish'] as String?,
        content: note['content'] as String,
        contentKurdish: note['contentKurdish'] as String?,
        examples: note['examples'] != null ? List<String>.from(note['examples']) : null,
        icon: Icons.public_rounded,
        color: Colors.orange,
      );
    }

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary600),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: content,
          ),
        ),

        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                if (!(_currentPhase == LessonPhase.introduction && _currentIntroPage == 0))
                  Expanded(
                    child: OutlinedCustomButton(
                      text: 'پێشوو',
                      onPressed: _previousIntroPage,
                      icon: Icons.arrow_back_rounded,
                    ),
                  ),
                if (!(_currentPhase == LessonPhase.introduction && _currentIntroPage == 0)) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    text: (_currentPhase == LessonPhase.culturalNotes && _currentIntroPage == _culturalNotes.length - 1) ||
                           (_currentPhase == LessonPhase.grammarNotes && _currentIntroPage == _grammarNotes.length - 1 && _culturalNotes.isEmpty) ||
                           (_currentPhase == LessonPhase.introduction && _currentIntroPage == _vocabulary.length - 1 && _grammarNotes.isEmpty && _culturalNotes.isEmpty)
                        ? 'دەست بکە بە ڕاهێنان'
                        : 'دواتر',
                    onPressed: _nextIntroPage,
                    icon: Icons.arrow_forward_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisePhase() {
    if (_exercises.isEmpty) {
      return const Center(child: Text('No exercises available'));
    }

    final currentExercise = _exercises[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / _exercises.length;
    final correctAnswer = currentExercise['correctAnswer'] as String;
    final isCorrect = _isAnswered &&
        _selectedAnswer?.toLowerCase().trim() ==
            correctAnswer.toLowerCase().trim();

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary600),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary600.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getExerciseTypeName(currentExercise['type'] as String),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  currentExercise['question'] as String,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
                ),
                const SizedBox(height: 8),
                if (currentExercise['questionKurdish'] != null)
                  Text(
                    currentExercise['questionKurdish'] as String,
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.4),
                    textDirection: TextDirection.rtl,
                  ),
                const SizedBox(height: 32),
                // Exercise Visual (Interactive for listening)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (currentExercise['type'] == 'listening') {
                        final textToSpeak = currentExercise['textToSpeak'] ?? 
                                          currentExercise['correctAnswer'] ?? 
                                          currentExercise['question'];
                        AudioService().playPronunciation(
                          textToSpeak as String, 
                          audioPath: currentExercise['audioPath'] as String?
                        );
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary600.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(60),
                        border: currentExercise['type'] == 'listening' 
                          ? Border.all(color: AppColors.primary600.withValues(alpha: 0.3), width: 2)
                          : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            _getExerciseIcon(currentExercise['type'] as String),
                            size: 60, 
                            color: AppColors.primary600
                          ),
                          if (currentExercise['type'] == 'listening')
                            Positioned(
                              bottom: 15,
                              right: 15,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary600,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (currentExercise['type'] == 'sentence_builder')
                  _buildSentenceBuilder()
                else if (currentExercise['options'] != null)
                  ...(currentExercise['options'] as List<dynamic>)
                      .map((option) {
                    final optionStr = option as String;
                    final isSelected = _selectedAnswer == optionStr;
                    final isCorrectOption = optionStr.toLowerCase().trim() ==
                        correctAnswer.toLowerCase().trim();

                    Color? backgroundColor;
                    Color? borderColor;
                    Color? textColor;

                    if (_isAnswered) {
                      if (isSelected) {
                        backgroundColor = isCorrect
                            ? AppColors.successLight
                            : AppColors.errorLight;
                        borderColor =
                            isCorrect ? AppColors.success : AppColors.error;
                        textColor =
                            isCorrect ? AppColors.success : AppColors.error;
                      } else if (isCorrectOption) {
                        backgroundColor = AppColors.successLight;
                        borderColor = AppColors.success;
                        textColor = AppColors.success;
                      }
                    } else if (isSelected) {
                      backgroundColor =
                          AppColors.primary600.withValues(alpha: 0.1);
                      borderColor = AppColors.primary600;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: backgroundColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _isAnswered
                              ? null
                              : () => _selectAnswer(optionStr),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: borderColor ?? AppColors.border,
                                  width: 2),
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
                                if (_isAnswered &&
                                    (isSelected || isCorrectOption))
                                  Icon(
                                    (isSelected && isCorrect) || isCorrectOption
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: (isSelected && isCorrect) ||
                                            isCorrectOption
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                
                if (currentExercise['type'] == 'sentence_builder' && !_isAnswered)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'پێداچوونەوە بکە', // "Check" in Kurdish
                        onPressed: _builtSentence.isEmpty ? null : _checkSentence,
                      ),
                    ),
                  ),

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
                          color:
                              isCorrect ? AppColors.success : AppColors.error,
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
        // Show "Check Answer" button when answer is selected but not checked
        // Show "Next" button when answer is checked
        if (_selectedAnswer != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: _isAnswered
                    ? PrimaryButton(
                        text: _currentExerciseIndex < _exercises.length - 1
                            ? AppTexts.next
                            : AppTexts.finish,
                        onPressed: _nextExercise,
                        icon: _currentExerciseIndex < _exercises.length - 1
                            ? Icons.arrow_forward_rounded
                            : Icons.check_rounded,
                      )
                    : PrimaryButton(
                        text: 'وەڵامەکەت بپشکنە',
                        onPressed: _checkAnswer,
                        icon: Icons.check_circle_outline_rounded,
                      ),
              ),
            ),
          ),
      ],
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

  IconData _getExerciseIcon(String type) {
    switch (type) {
      case 'listening':
        return Icons.volume_up_rounded;
      case 'fill_blank':
        return Icons.edit_note_rounded;
      case 'translation':
        return Icons.translate_rounded;
      case 'matching':
        return Icons.grid_view_rounded;
      case 'speaking':
        return Icons.mic_rounded;
      default:
        return Icons.school_rounded;
    }
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(AppTexts.yes,
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Target area (where selected words go)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _builtSentence.map((word) => _buildWordChip(word, false)).toList(),
          ),
        ),
        const SizedBox(height: 32),
        // Word bank (available words)
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _shuffledBank.map((word) => _buildWordChip(word, true)).toList(),
        ),
      ],
    );
  }

  Widget _buildWordChip(String word, bool fromBank) {
    return GestureDetector(
      onTap: () => _handleWordTap(word, fromBank),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Text(
          word,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// Lesson phases enum
enum LessonPhase {
  introduction,
  grammarNotes,
  culturalNotes,
  exercises,
}

// Vocabulary Introduction Card
class VocabularyIntroCard extends StatelessWidget {
  final String englishWord;
  final String kurdishTranslation;
  final String? audioPath;
  final String? exampleSentence;
  final String? exampleTranslation;
  final String? imageUrl;
  final String? notes;
  final String? notesKurdish;

  const VocabularyIntroCard({
    super.key,
    required this.englishWord,
    required this.kurdishTranslation,
    this.audioPath,
    this.exampleSentence,
    this.exampleTranslation,
    this.imageUrl,
    this.notes,
    this.notesKurdish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image or illustration
        if (imageUrl != null)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primary600.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 80,
                      color: AppColors.primary600.withValues(alpha: 0.3),
                    ),
                  );
                },
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary600.withValues(alpha: 0.2),
                  AppColors.primary600.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                Icons.school_rounded,
                size: 100,
                color: AppColors.primary600.withValues(alpha: 0.4),
              ),
            ),
          ),

        const SizedBox(height: 32),

        // English word with audio
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                englishWord,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (audioPath != null) ...[
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded),
                iconSize: 40,
                color: AppColors.primary600,
                onPressed: () {
                  // Play audio using TTS or file
                  AudioService().playPronunciation(englishWord, audioPath: audioPath);
                },
              ),
            ],
          ],
        ),

        const SizedBox(height: 32),

        // Kurdish translation box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary600.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary600.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const Text(
                'واتا بە کوردی:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                kurdishTranslation,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary600,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),

        // Example sentence
        if (exampleSentence != null) ...[
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.format_quote_rounded,
                        color: AppColors.success, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Example:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildExampleText(exampleSentence!),
                if (exampleTranslation != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    exampleTranslation!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ],
            ),
          ),
        ],

        if (notes != null || notesKurdish != null) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Notes / تێبینییەکان',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (notes != null)
                  Text(
                    notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (notes != null && notesKurdish != null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(height: 1, color: AppColors.info),
                  ),
                if (notesKurdish != null)
                  Text(
                    notesKurdish!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExampleText(String exampleSentence) {
    // For multi-word phrases, try to match the entire phrase first
    final vocabPhrase = englishWord.toLowerCase().trim();
    final sentenceLower = exampleSentence.toLowerCase();

    // Check if the sentence contains the exact vocabulary phrase
    if (sentenceLower.contains(vocabPhrase)) {
      // Find all occurrences of the phrase
      final List<InlineSpan> spans = [];
      int currentIndex = 0;

      while (currentIndex < exampleSentence.length) {
        final phraseIndex = sentenceLower.indexOf(vocabPhrase, currentIndex);

        if (phraseIndex == -1) {
          // Add remaining text
          spans.add(
            TextSpan(
              text: exampleSentence.substring(currentIndex),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          );
          break;
        }

        // Add text before the phrase
        if (phraseIndex > currentIndex) {
          spans.add(
            TextSpan(
              text: exampleSentence.substring(currentIndex, phraseIndex),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          );
        }

        // Add clickable phrase
        final originalPhrase = exampleSentence.substring(
          phraseIndex,
          phraseIndex + vocabPhrase.length,
        );
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: ClickableWord(
              englishWord: originalPhrase,
              kurdishTranslation: kurdishTranslation,
              audioPath: audioPath,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        );

        currentIndex = phraseIndex + vocabPhrase.length;
      }

      return RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 18, color: AppColors.textPrimary),
          children: spans,
        ),
      );
    } else {
      // Fall back to word-by-word matching for single words
      final words = exampleSentence.split(' ');
      final List<InlineSpan> spans = [];

      for (int i = 0; i < words.length; i++) {
        final word = words[i];
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
        final mainWord = englishWord.toLowerCase();

        // Check if this word matches our vocabulary word (case-insensitive)
        if (cleanWord == mainWord) {
          // Make it clickable
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: ClickableWord(
                englishWord: word,
                kurdishTranslation: kurdishTranslation,
                audioPath: audioPath,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
          );
        } else {
          // Regular text
          spans.add(
            TextSpan(
              text: word,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          );
        }

        // Add space between words (except last word)
        if (i < words.length - 1) {
          spans.add(const TextSpan(text: ' '));
        }
      }

      return RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 18, color: AppColors.textPrimary),
          children: spans,
        ),
      );
    }
  }
}

// New widget for Grammar and Cultural Notes
class LessonNoteCard extends StatelessWidget {
  final String title;
  final String? titleKurdish;
  final String content;
  final String? contentKurdish;
  final List<String>? examples;
  final IconData icon;
  final Color color;

  const LessonNoteCard({
    super.key,
    required this.title,
    this.titleKurdish,
    required this.content,
    this.contentKurdish,
    this.examples,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color),
          ),
        ),
        const SizedBox(height: 24),
        
        // Title
        Center(
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (titleKurdish != null) ...[
                const SizedBox(height: 4),
                Text(
                  titleKurdish!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Content
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
              if (contentKurdish != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(),
                ),
                Text(
                  contentKurdish!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ],
          ),
        ),

        // Examples
        if (examples != null && examples!.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text(
            'Examples / نموونەکان:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...examples!.map((example) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Text(
                example,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          )),
        ],
      ],
    );
  }
}
