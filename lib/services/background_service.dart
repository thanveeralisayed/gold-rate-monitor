import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'analytics_service.dart';
import 'gold_scraper_service.dart';
import 'notification_service.dart';

const String goldRatePeriodicTask = 'kerala_gold_rate_check_task';

/// Top-level callback dispatcher required by Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final scraper = GoldScraperService();

      // Check if scheduled window requires a scrape (once after 10am and once after 5pm)
      final shouldScrape = await scraper.shouldAutoScrape();
      if (!shouldScrape) {
        debugPrint('[BackgroundService] ⏳ Outside scheduled windows or already scraped for current session. Skipping network scrape.');
        return true;
      }

      // Perform live scrape for scheduled window
      final summary = await scraper.fetchGoldRates(forceScrape: true);
      final prefs = await SharedPreferences.getInstance();

      final lastPrice = prefs.getInt('last_saved_pavan_price') ?? 0;
      final lastDate = prefs.getString('last_saved_rate_date') ?? '';

      final currentPrice = summary.latestEntry.pavanPrice;
      final currentDate = summary.latestEntry.displayTitle;

      // If price or session date has changed from previous record
      if (lastPrice > 0 && (currentPrice != lastPrice || currentDate != lastDate)) {
        final change = currentPrice - lastPrice;
        final changeStr = change < 0
            ? 'dropped by ₹${(-change).toStringAsFixed(0)}'
            : change > 0
                ? 'rose by ₹${change.toStringAsFixed(0)}'
                : 'updated';

        final notifications = NotificationService();
        await notifications.init();
        await notifications.showGoldRateNotification(
          title: '✨ Kerala Gold Rate Updated!',
          body: '22K Gold $changeStr to ₹$currentPrice / Pavan (₹${(currentPrice / 8).toStringAsFixed(0)}/g)',
          id: 101,
        );
      }

      // Update storage with current values
      await prefs.setInt('last_saved_pavan_price', currentPrice);
      await prefs.setString('last_saved_rate_date', currentDate);
      await prefs.setString('last_check_timestamp', DateTime.now().toIso8601String());

      return true;
    } catch (e) {
      debugPrint('Background check error: $e');
      return false;
    }
  });
}

class BackgroundService {
  static bool _isRegistered = false;

  static Future<void> initialize() async {
    // Workmanager periodic tasks are only supported on Android & iOS
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    if (_isRegistered) return;

    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );

      // Register periodic background job (minimum interval on Android is 15 minutes)
      await Workmanager().registerPeriodicTask(
        goldRatePeriodicTask,
        goldRatePeriodicTask,
        frequency: const Duration(hours: 1),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );

      _isRegistered = true;
      debugPrint('Workmanager periodic gold rate task registered successfully');
    } catch (e) {
      debugPrint('Failed to initialize background service: $e');
    }
  }

  /// Manually checks now and triggers a notification if rate changed or if test is requested
  static Future<bool> checkNow({bool forceNotify = false}) async {
    try {
      final scraper = GoldScraperService();
      final summary = await scraper.fetchGoldRates();
      final prefs = await SharedPreferences.getInstance();

      final lastPrice = prefs.getInt('last_saved_pavan_price') ?? 0;
      final currentPrice = summary.latestEntry.pavanPrice;
      final currentDate = summary.latestEntry.displayTitle;

      bool shouldNotify = forceNotify || (lastPrice > 0 && lastPrice != currentPrice);

      if (shouldNotify) {
        final notifications = NotificationService();
        await notifications.init();

        final change = lastPrice > 0 ? currentPrice - lastPrice : summary.latestEntry.changePavan;
        final changeStr = change < 0
            ? 'dropped by ₹${(-change).toStringAsFixed(0)}'
            : change > 0
                ? 'rose by ₹${change.toStringAsFixed(0)}'
                : 'remains at';

        await notifications.showGoldRateNotification(
          title: forceNotify ? '🔔 Gold Rate Alert (Test)' : '✨ Kerala Gold Rate Updated!',
          body: '22K Gold $changeStr ₹$currentPrice / Pavan (₹${(currentPrice / 8).toStringAsFixed(0)}/g)',
          id: 101,
        );
      }

      await prefs.setInt('last_saved_pavan_price', currentPrice);
      await prefs.setString('last_saved_rate_date', currentDate);
      await prefs.setString('last_check_timestamp', DateTime.now().toIso8601String());

      AnalyticsService.logBackgroundRateCheck(
        rateChanged: shouldNotify,
        newPrice: currentPrice,
        oldPrice: lastPrice > 0 ? lastPrice : null,
        diff: lastPrice > 0 ? currentPrice - lastPrice : null,
      );

      return true;
    } catch (e) {
      debugPrint('checkNow error: $e');
      return false;
    }
  }
}
