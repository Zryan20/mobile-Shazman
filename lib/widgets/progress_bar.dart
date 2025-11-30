import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool showPercentage;
  final bool animated;
  final Duration animationDuration;
  final Gradient? gradient;
  
  const CustomProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.progressColor,
    this.backgroundColor,
    this.borderRadius,
    this.showPercentage = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgress = progress.clamp(0.0, 1.0);
    final effectiveProgressColor = progressColor ?? AppColors.primary600;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.neutral200;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(height / 2);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              children: [
                // Background
                Container(
                  color: effectiveBackgroundColor,
                ),
                
                // Progress
                animated
                    ? AnimatedContainer(
                        duration: animationDuration,
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: effectiveProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: gradient,
                              color: gradient == null ? effectiveProgressColor : null,
                            ),
                          ),
                        ),
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: effectiveProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: gradient,
                              color: gradient == null ? effectiveProgressColor : null,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${(effectiveProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// Circular progress bar variant
class CircularProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showPercentage;
  final Widget? child;
  
  const CircularProgressBar({
    super.key,
    required this.progress,
    this.size = 100.0,
    this.strokeWidth = 8.0,
    this.progressColor,
    this.backgroundColor,
    this.showPercentage = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgress = progress.clamp(0.0, 1.0);
    final effectiveProgressColor = progressColor ?? AppColors.primary600;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.neutral200;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveBackgroundColor),
            ),
          ),
          
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: effectiveProgress,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          
          // Center content
          if (child != null)
            child!
          else if (showPercentage)
            Text(
              '${(effectiveProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: effectiveProgressColor,
              ),
            ),
        ],
      ),
    );
  }
}

// Segmented progress bar (for multiple steps/stages)
class SegmentedProgressBar extends StatelessWidget {
  final int totalSegments;
  final int completedSegments;
  final double height;
  final double spacing;
  final Color? completedColor;
  final Color? incompleteColor;
  final BorderRadius? borderRadius;
  
  const SegmentedProgressBar({
    super.key,
    required this.totalSegments,
    required this.completedSegments,
    this.height = 8.0,
    this.spacing = 4.0,
    this.completedColor,
    this.incompleteColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCompletedColor = completedColor ?? AppColors.primary600;
    final effectiveIncompleteColor = incompleteColor ?? AppColors.neutral200;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(height / 2);
    
    return Row(
      children: List.generate(totalSegments, (index) {
        final isCompleted = index < completedSegments;
        
        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.only(
              right: index < totalSegments - 1 ? spacing : 0,
            ),
            decoration: BoxDecoration(
              color: isCompleted ? effectiveCompletedColor : effectiveIncompleteColor,
              borderRadius: effectiveBorderRadius,
            ),
          ),
        );
      }),
    );
  }
}

// Labeled progress bar (with label above)
class LabeledProgressBar extends StatelessWidget {
  final String label;
  final double progress;
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showPercentage;
  
  const LabeledProgressBar({
    super.key,
    required this.label,
    required this.progress,
    this.height = 8.0,
    this.progressColor,
    this.backgroundColor,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (showPercentage)
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: progressColor ?? AppColors.primary600,
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        CustomProgressBar(
          progress: progress,
          height: height,
          progressColor: progressColor,
          backgroundColor: backgroundColor,
          showPercentage: false,
        ),
      ],
    );
  }
}

// Gradient progress bar
class GradientProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final List<Color> gradientColors;
  final Color? backgroundColor;
  final bool showPercentage;
  
  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.gradientColors = const [
      Color(0xFF4CAF50),
      Color(0xFF8BC34A),
      Color(0xFFCDDC39),
      Color(0xFFFFEB3B),
      Color(0xFFFFC107),
      Color(0xFFFF9800),
    ],
    this.backgroundColor,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomProgressBar(
      progress: progress,
      height: height,
      backgroundColor: backgroundColor,
      showPercentage: showPercentage,
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    );
  }
}

// XP progress bar (with level information)
class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int requiredXP;
  final int currentLevel;
  final double height;
  
  const XPProgressBar({
    super.key,
    required this.currentXP,
    required this.requiredXP,
    required this.currentLevel,
    this.height = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = requiredXP > 0 ? currentXP / requiredXP : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppColors.xpGold,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Level $currentLevel',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '$currentXP / $requiredXP XP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        CustomProgressBar(
          progress: progress.clamp(0.0, 1.0),
          height: height,
          progressColor: AppColors.xpGold,
          gradient: LinearGradient(
            colors: [
              AppColors.xpGold,
              AppColors.xpGold.withOpacity(0.7),
            ],
          ),
          showPercentage: false,
        ),
      ],
    );
  }
}

// Streak progress bar (for daily goals)
class StreakProgressBar extends StatelessWidget {
  final int currentStreak;
  final int goalStreak;
  final double height;
  
  const StreakProgressBar({
    super.key,
    required this.currentStreak,
    this.goalStreak = 7,
    this.height = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goalStreak > 0 ? currentStreak / goalStreak : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.streakFire,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$currentStreak day streak',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              'Goal: $goalStreak days',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        CustomProgressBar(
          progress: progress.clamp(0.0, 1.0),
          height: height,
          progressColor: AppColors.streakFire,
          gradient: LinearGradient(
            colors: [
              AppColors.streakFire,
              Colors.orange,
            ],
          ),
          showPercentage: false,
        ),
      ],
    );
  }
}

// Animated loading bar
class AnimatedLoadingBar extends StatefulWidget {
  final double height;
  final Color? color;
  final Duration duration;
  
  const AnimatedLoadingBar({
    super.key,
    this.height = 4.0,
    this.color,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<AnimatedLoadingBar> createState() => _AnimatedLoadingBarState();
}

class _AnimatedLoadingBarState extends State<AnimatedLoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: null, // Indeterminate
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? AppColors.primary600,
            ),
            minHeight: widget.height,
          );
        },
      ),
    );
  }
}