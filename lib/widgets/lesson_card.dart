import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double progress; // 0.0 to 1.0
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? imageUrl;
  final int? xpReward;
  final String? duration;
  final Color? accentColor;
  final bool showProgress;
  
  const LessonCard({
    super.key,
    required this.title,
    this.subtitle,
    this.progress = 0.0,
    this.isLocked = false,
    this.isCompleted = false,
    this.onTap,
    this.icon,
    this.imageUrl,
    this.xpReward,
    this.duration,
    this.accentColor,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final effectiveAccentColor =
        accentColor ?? (isDark ? AppColors.primary400 : AppColors.primary600);
    
    // Theme-aware colors
    final cardColor = isLocked 
        ? (isDark ? AppColors.surfaceDark : Colors.grey[50]) 
        : (isDark ? AppColors.cardDark : Colors.white);
    
    final titleColor = isLocked
        ? AppColors.getTextTertiary(brightness)
        : AppColors.getTextPrimary(brightness);
        
    final subtitleColor = isLocked
        ? AppColors.getTextTertiary(brightness)
        : AppColors.getTextSecondary(brightness);
        
    final progressBgColor = isDark ? AppColors.surfaceDark : AppColors.neutral100;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : (isLocked ? 0.05 : 0.08)),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isCompleted 
              ? AppColors.success.withOpacity(0.2) 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: isLocked ? null : onTap,
          child: Stack(
            children: [
              if (isCompleted)
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 100,
                    color: AppColors.success.withOpacity(0.05),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildLeadingWidget(context, effectiveAccentColor),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: titleColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        _buildStatusIcon(context, effectiveAccentColor),
                      ],
                    ),
                    if (showProgress && !isLocked && !isCompleted) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: progressBgColor,
                                valueColor: AlwaysStoppedAnimation<Color>(effectiveAccentColor),
                                minHeight: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: effectiveAccentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLeadingWidget(BuildContext context, Color accentColor) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    
    if (isLocked) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.neutral200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          Icons.lock_outline_rounded,
          color: isDark ? AppColors.textTertiaryDark : AppColors.neutral400,
          size: 28,
        ),
      );
    }
    
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildIconContainer(accentColor);
          },
        ),
      );
    }
    
    return _buildIconContainer(accentColor);
  }
  
  Widget _buildIconContainer(Color accentColor) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withOpacity(0.12)
            : accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (isCompleted ? AppColors.success : accentColor).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon ?? Icons.auto_stories_rounded,
        color: isCompleted ? AppColors.success : accentColor,
        size: 28,
      ),
    );
  }
  
  Widget _buildStatusIcon(BuildContext context, Color accentColor) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    
    if (isLocked) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.neutral200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.lock_rounded,
          size: 20,
          color: isDark ? AppColors.textTertiaryDark : AppColors.neutral500,
        ),
      );
    }
    
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: AppColors.success,
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        size: 20,
        color: accentColor,
      ),
    );
  }
}

// Compact lesson card variant
class CompactLessonCard extends StatelessWidget {
  final String title;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback? onTap;
  final int? lessonNumber;
  
  const CompactLessonCard({
    super.key,
    required this.title,
    this.isLocked = false,
    this.isCompleted = false,
    this.onTap,
    this.lessonNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isLocked ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Lesson number circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success
                      : isLocked
                          ? AppColors.neutral300
                          : AppColors.primary600,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        )
                      : isLocked
                          ? const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              '${lessonNumber ?? ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isLocked
                        ? AppColors.neutral500
                        : AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Arrow icon
              if (!isLocked)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Level card variant (for A1-C2 levels)
class LevelCard extends StatelessWidget {
  final String levelName;
  final String description;
  final double progress;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback? onTap;
  final int? totalLessons;
  final int? completedLessons;
  
  const LevelCard({
    super.key,
    required this.levelName,
    required this.description,
    this.progress = 0.0,
    this.isLocked = false,
    this.isCompleted = false,
    this.onTap,
    this.totalLessons,
    this.completedLessons,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();
    
    return Card(
      elevation: isLocked ? 1 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: !isLocked
                ? LinearGradient(
                    colors: [
                      levelColor.withOpacity(0.1),
                      levelColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? AppColors.neutral300
                          : levelColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      levelName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Status icon
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 28,
                    )
                  else if (isLocked)
                    const Icon(
                      Icons.lock_rounded,
                      color: AppColors.neutral500,
                      size: 28,
                    )
                  else if (progress > 0)
                    Icon(
                      Icons.play_circle_rounded,
                      color: levelColor,
                      size: 28,
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isLocked
                      ? AppColors.neutral500
                      : AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (!isLocked) ...[
                const SizedBox(height: 16),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                    minHeight: 8,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Lesson count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (totalLessons != null && completedLessons != null)
                      Text(
                        '$completedLessons/$totalLessons lessons',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getLevelColor() {
    if (levelName.startsWith('A1') || levelName.startsWith('A2')) {
      return AppColors.beginner;
    } else if (levelName.startsWith('B1') || levelName.startsWith('B2')) {
      return AppColors.intermediate;
    } else if (levelName.startsWith('C1') || levelName.startsWith('C2')) {
      return AppColors.advanced;
    }
    return AppColors.primary600;
  }
}