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
    final effectiveAccentColor = accentColor ?? AppColors.primary600;
    
    return Card(
      elevation: isLocked ? 1 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isCompleted
                ? LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.1),
                      AppColors.success.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: isCompleted
                ? Border.all(
                    color: AppColors.success.withOpacity(0.3),
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon or Image
                  _buildLeadingWidget(effectiveAccentColor),
                  
                  const SizedBox(width: 12),
                  
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? AppColors.neutral500
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isLocked
                                  ? AppColors.neutral400
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Status icon
                  _buildStatusIcon(effectiveAccentColor),
                ],
              ),
              
              // Progress bar (if not locked and not completed)
              if (showProgress && !isLocked && !isCompleted && progress > 0) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveAccentColor),
                    minHeight: 6,
                  ),
                ),
              ],
              
              // Bottom info (XP, duration, progress percentage)
              if ((xpReward != null || duration != null || (showProgress && !isLocked && !isCompleted)) &&
                  !isLocked) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // XP Reward
                    if (xpReward != null) ...[
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.xpGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$xpReward XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    
                    // Duration
                    if (duration != null) ...[
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    
                    const Spacer(),
                    
                    // Progress percentage
                    if (showProgress && !isCompleted && progress > 0) ...[
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: effectiveAccentColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLeadingWidget(Color accentColor) {
    if (isLocked) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.lock_rounded,
          color: AppColors.neutral500,
          size: 24,
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withOpacity(0.1)
            : accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon ?? Icons.book_rounded,
        color: isCompleted ? AppColors.success : accentColor,
        size: 24,
      ),
    );
  }
  
  Widget _buildStatusIcon(Color accentColor) {
    if (isLocked) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.lock_rounded,
          size: 20,
          color: AppColors.neutral500,
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
        child: Icon(
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
                Icon(
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
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 28,
                    )
                  else if (isLocked)
                    Icon(
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
                        style: TextStyle(
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