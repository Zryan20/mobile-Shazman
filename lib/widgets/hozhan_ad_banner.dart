import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// A wrapper widget for ads that only displays its content if the user is not premium.
/// This ensures premium users never even initialize an ad request.
class HozhanAdBanner extends StatelessWidget {
  final Widget adChild;

  const HozhanAdBanner({
    super.key,
    required this.adChild,
  });

  @override
  Widget build(BuildContext context) {
    // Check if user is premium
    final isPremium = Provider.of<UserProvider>(context).isPremium;

    if (isPremium) {
      // Premium users see nothing, and the adChild (ad request) is never built
      return const SizedBox.shrink();
    }

    // Regular users see the ad
    return adChild;
  }
}
