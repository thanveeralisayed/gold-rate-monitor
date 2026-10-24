import 'package:flutter_test/flutter_test.dart';
import 'package:gold_rate_monitor/services/analytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsService Unit Tests', () {
    test('initialization handles unconfigured environment gracefully without throwing', () async {
      // In a unit test environment without native Firebase channels, it should catch gracefully
      await expectLater(AnalyticsService.initialize(), completes);
      expect(AnalyticsService.isInitialized, isFalse);
    });

    test('event logging methods complete safely in fallback mode', () async {
      await expectLater(AnalyticsService.logAppOpen(), completes);

      await expectLater(
        AnalyticsService.logScreenView(
          screenName: 'HomeScreen',
          screenClass: 'HomeScreenState',
        ),
        completes,
      );

      await expectLater(
        AnalyticsService.logRateUnitToggle(isPavan: true),
        completes,
      );

      await expectLater(
        AnalyticsService.logRateUnitToggle(isPavan: false),
        completes,
      );

      await expectLater(
        AnalyticsService.logRateRefresh(
          isManual: true,
          success: true,
          pavanPrice: 104480,
          gramPrice: 13060.0,
          trend: 'Downward',
          durationMs: 350,
        ),
        completes,
      );

      await expectLater(
        AnalyticsService.logCalculatorOpen(currentGramRate: 13060.0),
        completes,
      );

      await expectLater(
        AnalyticsService.logCalculatorCalculation(
          weightInGrams: 8.0,
          makingChargePercent: 8.0,
          includeGst: true,
          grandTotal: 116248.0,
        ),
        completes,
      );

      await expectLater(
        AnalyticsService.logChartPeriodChange(period: '7D'),
        completes,
      );

      await expectLater(
        AnalyticsService.logTestNotificationTriggered(),
        completes,
      );

      await expectLater(
        AnalyticsService.logBackgroundRateCheck(
          rateChanged: true,
          newPrice: 105000,
          oldPrice: 104480,
          diff: 520,
        ),
        completes,
      );

      await expectLater(
        AnalyticsService.setUserProperty(
          name: 'preferred_unit',
          value: 'pavan',
        ),
        completes,
      );

      await expectLater(
        AnalyticsService.logCustomEvent(
          name: 'custom_gold_action',
          parameters: {'action': 'share_rate'},
        ),
        completes,
      );
    });

    test('observer property is safely accessible without errors', () {
      expect(() => AnalyticsService.observer, returnsNormally);
    });
  });
}
