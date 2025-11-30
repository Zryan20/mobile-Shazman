import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/lesson_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

class LearningPathScreen extends StatefulWidget {
  final int level;

  const LearningPathScreen({
    super.key,
    required this.level,
  });

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getLevelName(int level) {
    switch (level) {
      case 1: return 'A1 - دەستپێک';
      case 2: return 'A2 - سەرەتایی';
      case 3: return 'B1 - ناوەند';
      case 4: return 'B2 - ناوەندی بەرز';
      case 5: return 'C1 - پێشکەوتوو';
      case 6: return 'C2 - شارەزایی';
      default: return 'نامۆ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer2<LessonProvider, ProgressProvider>(
        builder: (context, lessonProvider, progressProvider, child) {
          final lessons = lessonProvider.getLessonsByLevel(widget.level);
          
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary600,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    _getLevelName(widget.level),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary600,
                          AppColors.primary700,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Learning Path
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Group lessons into sections (3 lessons per section for A1)
                      final sectionsData = _groupLessonsIntoSections(lessons);
                      
                      if (index >= sectionsData.length) return null;
                      
                      final section = sectionsData[index];
                      final isLastSection = index == sectionsData.length - 1;
                      
                      return Column(
                        children: [
                          // Section Header
                          _SectionHeader(
                            sectionNumber: section['number'],
                            title: section['title'],
                            subtitle: section['subtitle'],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Lesson Nodes in Path
                          ...List.generate(section['lessons'].length, (lessonIndex) {
                            final lesson = section['lessons'][lessonIndex];
                            final isCompleted = progressProvider.isLessonCompleted(lesson.id);
                            final isUnlocked = lessonIndex == 0 || 
                                progressProvider.isLessonCompleted(
                                  section['lessons'][lessonIndex - 1].id
                                );
                            final isCurrent = !isCompleted && isUnlocked;
                            
                            // Alternate left/right positioning
                            final isLeft = lessonIndex % 2 == 0;
                            
                            return Column(
                              children: [
                                _LessonNode(
                                  lesson: lesson,
                                  isLeft: isLeft,
                                  isCompleted: isCompleted,
                                  isUnlocked: isUnlocked,
                                  isCurrent: isCurrent,
                                  onTap: isUnlocked ? () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.lesson,
                                      arguments: {'lessonId': lesson.id},
                                    );
                                  } : null,
                                ),
                                
                                // Connecting line to next lesson
                                if (lessonIndex < section['lessons'].length - 1)
                                  _ConnectingLine(
                                    isCompleted: isCompleted,
                                    isUnlocked: isUnlocked,
                                  ),
                              ],
                            );
                          }),
                          
                          // Section completion celebration
                          if (section['lessons'].every((l) => 
                              progressProvider.isLessonCompleted(l.id)))
                            _SectionCompleteWidget(),
                          
                          if (!isLastSection) const SizedBox(height: 40),
                        ],
                      );
                    },
                    childCount: _groupLessonsIntoSections(lessons).length,
                  ),
                ),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _groupLessonsIntoSections(List lessons) {
    // For A1, we have 7 sections with 3 lessons each (21 total)
    final sections = <Map<String, dynamic>>[];
    
    final sectionTitles = [
      {'title': 'بەشی یەکەم', 'subtitle': 'دەستەواژە بنەڕەتییەکان'},
      {'title': 'بەشی دووەم', 'subtitle': 'ژمارە و ڕەنگەکان'},
      {'title': 'بەشی سێیەم', 'subtitle': 'خواردن و خواردنەوە'},
      {'title': 'بەشی چوارەم', 'subtitle': 'کات و ڕۆژەکان'},
      {'title': 'بەشی پێنجەم', 'subtitle': 'گفتوگۆی ڕۆژانە'},
      {'title': 'بەشی شەشەم', 'subtitle': 'شوێن و ئاراستە'},
      {'title': 'بەشی حەوتەم', 'subtitle': 'پێداچوونەوە و تاقیکردنەوە'},
    ];
    
    int lessonIndex = 0;
    for (int i = 0; i < 7; i++) {
      final sectionLessons = <dynamic>[];
      for (int j = 0; j < 3 && lessonIndex < lessons.length; j++) {
        sectionLessons.add(lessons[lessonIndex]);
        lessonIndex++;
      }
      
      if (sectionLessons.isNotEmpty) {
        sections.add({
          'number': i + 1,
          'title': sectionTitles[i]['title'],
          'subtitle': sectionTitles[i]['subtitle'],
          'lessons': sectionLessons,
        });
      }
    }
    
    return sections;
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final int sectionNumber;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.sectionNumber,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary600.withOpacity(0.1),
            AppColors.primary700.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary600.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$sectionNumber',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Lesson Node Widget (the circles on the path)
class _LessonNode extends StatelessWidget {
  final dynamic lesson;
  final bool isLeft;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _LessonNode({
    required this.lesson,
    required this.isLeft,
    required this.isCompleted,
    required this.isUnlocked,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final nodeSize = 80.0;
    final offset = screenWidth * 0.15;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          left: isLeft ? offset : screenWidth - offset - nodeSize - 40,
          right: isLeft ? screenWidth - offset - nodeSize - 40 : offset,
        ),
        child: Column(
          children: [
            // Lesson Circle
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow for current lesson
                if (isCurrent)
                  Container(
                    width: nodeSize + 20,
                    height: nodeSize + 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary600.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                
                // Main circle
                Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isCompleted
                          ? [Colors.green[400]!, Colors.green[600]!]
                          : isUnlocked
                              ? [AppColors.primary500, AppColors.primary700]
                              : [Colors.grey[300]!, Colors.grey[400]!],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_rounded
                        : isUnlocked
                            ? Icons.play_arrow_rounded
                            : Icons.lock_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                
                // Pulse animation for current lesson
                if (isCurrent)
                Container(
                  width: nodeSize + 20,
                  height: nodeSize + 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary600.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Lesson Title
            Container(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                lesson.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: isUnlocked ? Colors.black87 : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Progress indicator
            if (isCompleted)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'تەواو بوو',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Connecting Line between lessons
class _ConnectingLine extends StatelessWidget {
  final bool isCompleted;
  final bool isUnlocked;

  const _ConnectingLine({
    required this.isCompleted,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCompleted
              ? [Colors.green[400]!, Colors.green[600]!]
              : isUnlocked
                  ? [AppColors.primary500, AppColors.primary700]
                  : [Colors.grey[300]!, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// Section Complete Widget
class _SectionCompleteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[300]!, Colors.orange[400]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              'بەشەکە تەواو کرا!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

