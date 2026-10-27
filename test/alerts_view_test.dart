import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_rate_monitor/widgets/alerts_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'price_alerts_enabled': true});
  });

  Widget createTestWidget({Future<void> Function()? onTriggerTestNotification}) {
    return MaterialApp(
      home: Scaffold(
        body: AlertsView(
          onTriggerTestNotification: onTriggerTestNotification,
        ),
      ),
    );
  }

  group('AlertsView Widget Tests', () {
    testWidgets('renders header, engine status, and schedule cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('NOTIFICATION CENTER'), findsOneWidget);
      expect(find.text('Price Alerts'), findsOneWidget);
      expect(find.text('Background Engine Active'), findsOneWidget);
      expect(find.text('OPTIMIZED'), findsOneWidget);

      expect(find.text('10:00 AM'), findsOneWidget);
      expect(find.text('Morning Market Open'), findsOneWidget);
      expect(find.text('05:00 PM'), findsOneWidget);
      expect(find.text('Evening Session Fix'), findsOneWidget);
      expect(find.text('Primary Window'), findsOneWidget);
      expect(find.text('Secondary Window'), findsOneWidget);
    });

    testWidgets('toggling master alert switch updates state and preferences', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final switchWidget = find.byType(Switch);
      expect(switchWidget, findsOneWidget);

      Switch s = tester.widget<Switch>(switchWidget);
      expect(s.value, isTrue);

      await tester.tap(switchWidget);
      await tester.pumpAndSettle();

      s = tester.widget<Switch>(switchWidget);
      expect(s.value, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('price_alerts_enabled'), isFalse);
    });

    testWidgets('tapping Send Sample Alert button calls callback', (tester) async {
      bool triggered = false;
      await tester.pumpWidget(createTestWidget(
        onTriggerTestNotification: () async {
          triggered = true;
        },
      ));
      await tester.pumpAndSettle();

      final testBtn = find.text('Send Sample Alert');
      expect(testBtn, findsOneWidget);

      await tester.tap(testBtn);
      await tester.pump();

      expect(triggered, isTrue);
    });

    testWidgets('renders rate limit protection policy note', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('To protect KeralaGold.com from rate limits'),
        findsOneWidget,
      );
    });
  });
}
