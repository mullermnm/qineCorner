import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  return PremiumNotifier();
});

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier() : super(false) {
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('is_premium') ?? false;
  }

  Future<void> upgradeToPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    state = true;
  }

  Future<void> downgrade() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', false);
    state = false;
  }
}
