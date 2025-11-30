import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hearts_provider.dart';
import '../utils/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    const Text(
                      'Shazman+',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              
              // Premium badge
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[400]!, Colors.amber[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'بەرزبکەرەوە بۆ Shazman+',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'فێربوونی بێسنوور بەبێ سنوورەکان',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Features list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildFeature(
                      icon: Icons.favorite,
                      title: 'دڵی بێسنوور',
                      description: 'هەرگیز دڵ لەدەست مەدە و بێ وەستان فێرببە',
                      color: Colors.red,
                    ),
                    
                    _buildFeature(
                      icon: Icons.block_rounded,
                      title: 'بێ ڕێکلام',
                      description: 'ژینگەیەکی پاک بەبێ ڕێکلامەکان',
                      color: Colors.green,
                    ),
                    
                    _buildFeature(
                      icon: Icons.speed_rounded,
                      title: 'دەستڕاگەیشتنی پێشوەختە',
                      description: 'دەستڕاگەیشتن بە تایبەتمەندییەکانی نوێ پێش کەسانی تر',
                      color: Colors.blue,
                    ),
                    
                    _buildFeature(
                      icon: Icons.trending_up_rounded,
                      title: 'ئامارەکانی پێشکەوتوو',
                      description: 'شیکاری قووڵ لە پێشکەوتنەکەت',
                      color: Colors.purple,
                    ),
                    
                    _buildFeature(
                      icon: Icons.download_rounded,
                      title: 'دابەزاندنی دەرسەکان',
                      description: 'فێربوون بەبێ ئینتەرنێت',
                      color: Colors.orange,
                    ),
                    
                    _buildFeature(
                      icon: Icons.support_agent_rounded,
                      title: 'پشتگیری تایبەت',
                      description: 'یارمەتی خێرا و لە پێشینە',
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Pricing cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildPricingCard(
                      context,
                      title: 'مانگانە',
                      price: '١٥,٠٠٠',
                      period: 'مانگ',
                      savings: null,
                      isPopular: false,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildPricingCard(
                      context,
                      title: 'ساڵانە',
                      price: '١٠٠,٠٠٠',
                      period: 'ساڵ',
                      savings: 'پاشەکەوتکردنی ٨٠,٠٠٠ دینار',
                      isPopular: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Trial info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '٧ ڕۆژ تاقیکردنەوەی بەخۆڕایی بۆ بەشداربووانی نوێ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Legal text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'بە کلیککردن لەسەر "دەستپێکردنی تاقیکردنەوە"، تۆ ڕازی دەبیت بە مەرجەکانی خزمەتگوزاری و سیاسەتی تایبەتێتیمان.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPricingCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    String? savings,
    required bool isPopular,
  }) {
    return GestureDetector(
      onTap: () => _selectPlan(context, title, price),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPopular ? Colors.amber[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? Colors.amber : Colors.grey[300]!,
            width: isPopular ? 2.5 : 1.5,
          ),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPopular ? Colors.amber[900] : Colors.black,
                  ),
                ),
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'باوترین',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isPopular ? Colors.amber[900] : Colors.black,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'دینار',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            
            Text(
              'بۆ $period',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            
            if (savings != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  savings,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[900],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _selectPlan(BuildContext context, String plan, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('خەریکی $plan'),
        content: Text('دڵنیای کە دەتەوێت Shazman+ بکڕیت بە $price دینار؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('پاشگەزبوونەوە'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Activate premium
              await context.read<HeartsProvider>().purchasePremium();
              
              // Show success
              if (!context.mounted) return;
              Navigator.pop(context); // Close premium screen
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Shazman+ چالاککرا! دڵی بێسنوورت هەیە! 💎'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text('کڕین'),
          ),
        ],
      ),
    );
  }
}