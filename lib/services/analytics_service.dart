import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Service providing unified, type-safe Firebase Analytics tracking across the application.
/// 
/// Gracefully falls back to debug console logging if Firebase is not yet configured
/// with credentials (e.g., during development or testing), preventing runtime crashes.
class AnalyticsService {
  AnalyticsService._();

  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;
  static bool _isInitialized = false;

  /// Returns whether Firebase Analytics is initialized and actively sending events.
  static bool get isInitialized => _isInitialized;

  /// Returns the FirebaseAnalyticsObserver instance to attach to MaterialApp.navigatorObservers.
  static FirebaseAnalyticsObserver? get observer => _observer;

  /// Underlying FirebaseAnalytics instance, if initialized.
  static FirebaseAnalytics? get instance => _analytics;

  /// Initializes Firebase and Firebase Analytics safely.
  static Future<void> initialize({FirebaseOptions? options}) async {
    try {
      if (Firebase.apps.isEmpty) {
        if (options != null) {
          await Firebase.initializeApp(options: options);
        } else {
          await Firebase.initializeApp();
        }
      }

      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      _isInitialized = true;

      // Enable analytics collection
      await _analytics!.setAnalyticsCollectionEnabled(true);

      debugPrint('[AnalyticsService] ✅ Firebase Analytics successfully initialized.');
      await logAppOpen();
    } catch (e) {
      _isInitialized = false;
      _analytics = null;
      _observer = null;
      debugPrint(
        '[AnalyticsService] ℹ️ Firebase credentials not detected or failed to initialize ($e). '
        'Events will safely fall back to debug log output without interrupting application flow.',
      );
    }
  }

  /// Logs app launch / open event.
  static Future<void> logAppOpen() async {
    await _logEvent(name: 'app_open');
  }

  /// Logs screen views for user flow analytics.
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (_isInitialized && _analytics != null) {
      try {
        await _analytics!.logScreenView(
          screenName: screenName,
          screenClass: screenClass ?? screenName,
        );
      } catch (e) {
        debugPrint('[AnalyticsService] Error logging screen view: $e');
      }
    }
    final debugParams = <String, Object>{'screen_name': screenName};
    if (screenClass != null) debugParams['screen_class'] = screenClass;
    _debugLog('screen_view', debugParams);
  }

  /// Logs toggling between Pavan (8g) and Gram (1g) display modes.
  static Future<void> logRateUnitToggle({required bool isPavan}) async {
    await _logEvent(
      name: 'unit_toggled',
      parameters: {
        'unit': isPavan ? 'pavan' : 'gram',
        'unit_grams': isPavan ? 8 : 1,
      },
    );
  }

  /// Logs gold rate refresh attempts (manual pull-to-refresh or automatic initial fetch).
  static Future<void> logRateRefresh({
    required bool isManual,
    required bool success,
    int? pavanPrice,
    double? gramPrice,
    String? trend,
    int? durationMs,
  }) async {
    final params = <String, Object>{
      'refresh_type': isManual ? 'manual_pull' : 'initial_load',
      'success': success,
    };
    if (pavanPrice != null) params['pavan_price'] = pavanPrice;
    if (gramPrice != null) params['gram_price'] = gramPrice.round();
    if (trend != null) params['trend'] = trend;
    if (durationMs != null) params['duration_ms'] = durationMs;

    await _logEvent(
      name: 'rates_refreshed',
      parameters: params,
    );
  }

  /// Logs when the user opens the gold calculator sheet.
  static Future<void> logCalculatorOpen({required double currentGramRate}) async {
    await _logEvent(
      name: 'calculator_opened',
      parameters: {
        'current_gram_rate': currentGramRate.round(),
      },
    );
  }

  /// Logs when the user performs or interacts with price calculations in the calculator.
  static Future<void> logCalculatorCalculation({
    required double weightInGrams,
    required double makingChargePercent,
    required bool includeGst,
    required double grandTotal,
  }) async {
    await _logEvent(
      name: 'calculator_computed',
      parameters: {
        'weight_grams': weightInGrams,
        'making_charge_pct': makingChargePercent,
        'include_gst': includeGst,
        'grand_total': grandTotal.round(),
      },
    );
  }

  /// Logs selection of different historical chart periods (7 Days, 14 Days, Full Month).
  static Future<void> logChartPeriodChange({required String period}) async {
    await _logEvent(
      name: 'chart_period_selected',
      parameters: {
        'period': period,
      },
    );
  }

  /// Logs when user triggers a manual test notification from the header.
  static Future<void> logTestNotificationTriggered() async {
    await _logEvent(name: 'test_notification_triggered');
  }

  /// Logs periodic background price checks and alerts dispatched.
  static Future<void> logBackgroundRateCheck({
    required bool rateChanged,
    int? newPrice,
    int? oldPrice,
    int? diff,
  }) async {
    final params = <String, Object>{'rate_changed': rateChanged};
    if (newPrice != null) params['new_price'] = newPrice;
    if (oldPrice != null) params['old_price'] = oldPrice;
    if (diff != null) params['price_difference'] = diff;

    await _logEvent(
      name: 'background_check_executed',
      parameters: params,
    );
  }

  /// Sets a persistent user property in Firebase Analytics.
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (_isInitialized && _analytics != null) {
      try {
        await _analytics!.setUserProperty(name: name, value: value);
      } catch (e) {
        debugPrint('[AnalyticsService] Error setting user property $name: $e');
      }
    }
    _debugLog('user_property', {'name': name, 'value': value ?? 'null'});
  }

  /// Logs a custom event with optional parameters.
  static Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _logEvent(name: name, parameters: parameters);
  }

  /// Internal helper to dispatch to Firebase Analytics if available, and debug console in debug mode.
  static Future<void> _logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (_isInitialized && _analytics != null) {
      try {
        await _analytics!.logEvent(
          name: name,
          parameters: parameters,
        );
      } catch (e) {
        debugPrint('[AnalyticsService] Error logging event $name: $e');
      }
    }
    _debugLog(name, parameters);
  }

  static void _debugLog(String eventName, Map<String, Object?>? params) {
    if (kDebugMode) {
      final paramStr = params != null && params.isNotEmpty ? ' | Params: $params' : '';
      debugPrint('[AnalyticsService] 📊 Event: "$eventName"$paramStr');
    }
  }
}
