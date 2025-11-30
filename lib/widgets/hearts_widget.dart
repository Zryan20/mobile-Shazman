import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hearts_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

/// Hearts display widget for app bar
class HeartsAppBarWidget extends StatelessWidget {
  final bool showLabel;
  
  const HeartsAppBarWidget({
    super.key,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HeartsProvider>(
      builder: (context, heartsProvider, child) {
        return GestureDetector(
          onTap: () {
            _showHeartsDialog(context, heartsProvider);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: heartsProvider.isPremium 
                  ? Colors.amber[100] 
                  : Colors.red[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: heartsProvider.isPremium 
                    ? Colors.amber 
                    : Colors.red[200]!,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  heartsProvider.isPremium 
                      ? Icons.workspace_premium_rounded 
                      : Icons.favorite,
                  color: heartsProvider.isPremium 
                      ? Colors.amber[700] 
                      : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  heartsProvider.isPremium 
                      ? '∞' 
                      : '${heartsProvider.currentHearts}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: heartsProvider.isPremium 
                        ? Colors.amber[900] 
                        : Colors.red[900],
                  ),
                ),
                if (showLabel) ...[
                  const SizedBox(width: 4),
                  Text(
                    heartsProvider.isPremium ? 'Shazman+' : 'دڵ',
                    style: TextStyle(
                      fontSize: 12,
                      color: heartsProvider.isPremium 
                          ? Colors.amber[900] 
                          : Colors.red[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showHeartsDialog(BuildContext context, HeartsProvider heartsProvider) {
    showDialog(
      context: context,
      builder: (context) => HeartsInfoDialog(heartsProvider: heartsProvider),
    );
  }
}

/// Detailed hearts info dialog
class HeartsInfoDialog extends StatelessWidget {
  final HeartsProvider heartsProvider;
  
  const HeartsInfoDialog({
    super.key,
    required this.heartsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: heartsProvider.isPremium 
                    ? Colors.amber[100] 
                    : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                heartsProvider.isPremium 
                    ? Icons.workspace_premium_rounded 
                    : Icons.favorite,
                size: 40,
                color: heartsProvider.isPremium 
                    ? Colors.amber[700] 
                    : Colors.red,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              heartsProvider.isPremium ? 'Shazman+ چالاکە' : 'سیستەمی دڵەکان',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Hearts display
            if (!heartsProvider.isPremium) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  HeartsProvider.MAX_HEARTS,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < heartsProvider.currentHearts 
                          ? Icons.favorite 
                          : Icons.favorite_border,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Hearts count
              Text(
                '${heartsProvider.currentHearts}/${HeartsProvider.MAX_HEARTS} دڵ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                heartsProvider.isPremium 
                    ? 'تۆ بەشداربووی Shazman+ یت! دڵی بێسنوورت هەیە و دەتوانیت بێ سنوور فێربیت. 💎'
                    : 'ئەگەر هەڵە بکەیت، دڵێک لەدەست دەدەیت. هەر دڵێک لە ٥ کاتژمێردا دەگەڕێتەوە. 💖',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Recovery timer
            if (!heartsProvider.isPremium && 
                heartsProvider.currentHearts < HeartsProvider.MAX_HEARTS) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_rounded, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'دڵی دواتر: ${heartsProvider.formattedTimeUntilNextHeartArabic}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Action buttons
            if (!heartsProvider.isPremium) ...[
              // Refill hearts button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showRefillOptions(context);
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text('پڕکردنەوەی دڵەکان'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Upgrade to premium
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.premium);
                  },
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: const Text('بەرزکردنەوە بۆ Shazman+'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber[700],
                    side: BorderSide(color: Colors.amber[700]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ] else ...[
              // Premium status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[100]!, Colors.amber[50]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[700]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Shazman+ چالاکە',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('داخستن'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _showRefillOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RefillHeartsSheet(),
    );
  }
}

/// Bottom sheet with refill options
class RefillHeartsSheet extends StatelessWidget {
  const RefillHeartsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'پڕکردنەوەی دڵەکان',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Watch ad option
            _buildRefillOption(
              context,
              icon: Icons.play_circle_outline,
              title: 'تەماشای ڕێکلام بکە',
              subtitle: 'وەرگرتنی ١ دڵ بە خۆڕایی',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _watchAdForHeart(context);
              },
            ),
            
            const SizedBox(height: 12),
            

            
            // Premium option
            _buildRefillOption(
              context,
              icon: Icons.workspace_premium_rounded,
              title: 'Shazman+ بکڕە',
              subtitle: 'دڵی بێسنوور بۆ هەمیشە!',
              color: Colors.amber,
              isPremium: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.premium);
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRefillOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'باشترین',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _watchAdForHeart(BuildContext context) async {
    // TODO: Show rewarded ad
    // Simulate watching ad
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (!context.mounted) return;
    Navigator.pop(context);
    
    // Recover one heart
    await context.read<HeartsProvider>().recoverHeart();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('سوپاس! ١ دڵت وەرگرت 💖'),
        backgroundColor: Colors.green,
      ),
    );
  }

}

/// Hearts warning widget (show when hearts are low)
class HeartsWarningBanner extends StatelessWidget {
  const HeartsWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HeartsProvider>(
      builder: (context, heartsProvider, child) {
        final warning = heartsProvider.getLowHeartsWarning();
        
        if (warning == null) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.orange[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  warning,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}