import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_rate_monitor/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const sampleHtml = '''
    <!DOCTYPE html>
    <html>
    <head><title>Today Gold Rate Kerala - October 2026</title></head>
    <body>
      <table>
        <tr><td>Highest:</td><td>10th Oct</td><td>Rs. 1,11,040</td></tr>
        <tr><td>Lowest:</td><td>23rd Oct</td><td>Rs. 1,04,480</td></tr>
      </table>
      <table>
        <tr><td>Today's Gold Price Trend : Downward</td></tr>
      </table>
      <table>
        <tr><td>Date</td><td>Price of 1 Pavan Gold (Rs.)</td></tr>
        <tr><td>1-Oct-26</td><td>109440</td></tr>
        <tr><td>2-Oct-26</td><td>110200</td></tr>
        <tr><td>23-Oct-26 Today »</td><td>Rs. 1,04,480</td></tr>
      </table>
    </body>
    </html>
  ''';

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'price_alerts_enabled': true,
      'cached_gold_html': sampleHtml,
      'cached_gold_timestamp': DateTime.now().toIso8601String(),
    });
  });

  Widget createTestApp() {
    return const GoldRateApp();
  }

  group('HomeScreen 4-Tab Navigation Tests', () {
    testWidgets('renders all 4 bottom navigation items', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Rates'), findsOneWidget);
      expect(find.text('Ledger'), findsOneWidget);
      expect(find.text('Calculator'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
    });

    testWidgets('starts on Rates tab by default', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('MARKET OPENS AT 10:00 AM • INTRA-DAY SYNC ACTIVE'), findsOneWidget);
      expect(find.text('Market Bias: Bearish'), findsWidgets);
    });

    testWidgets('switches to Ledger tab and renders HistoryView', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ledger'));
      await tester.pumpAndSettle();

      expect(find.text('RATE ARCHIVE'), findsOneWidget);
      expect(find.text('MONTH HIGH'), findsOneWidget);
      expect(find.text('MONTH LOW'), findsOneWidget);
      expect(find.text('SESSION LEDGER'), findsOneWidget);
    });

    testWidgets('switches to Calculator tab and renders CalculatorView', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calculator'));
      await tester.pumpAndSettle();

      expect(find.text('JEWELLERY ESTIMATOR'), findsOneWidget);
      expect(find.text('LIVE BENCHMARK'), findsOneWidget);
      expect(find.text('ESTIMATED BILL BREAKDOWN'), findsOneWidget);
    });

    testWidgets('switches to Alerts tab and renders AlertsView', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alerts'));
      await tester.pumpAndSettle();

      expect(find.text('NOTIFICATION CENTER'), findsOneWidget);
      expect(find.text('Background Engine Active'), findsOneWidget);
      expect(find.text('10:00 AM'), findsOneWidget);
      expect(find.text('05:00 PM'), findsOneWidget);
    });

    testWidgets('tapping shortcut on Rates tab switches directly to Calculator tab', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find the "Calculate" button on the Rates tab CTA card
      final calcBtn = find.text('Calculate');
      await tester.scrollUntilVisible(calcBtn, 300);
      await tester.tap(calcBtn);
      await tester.pumpAndSettle();

      // Should now be on Calculator view
      expect(find.text('JEWELLERY ESTIMATOR'), findsOneWidget);
      expect(find.text('ESTIMATED BILL BREAKDOWN'), findsOneWidget);
    });
  });
}
