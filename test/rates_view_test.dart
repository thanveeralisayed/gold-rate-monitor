import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_rate_monitor/models/gold_rate_model.dart';
import 'package:gold_rate_monitor/widgets/rates_view.dart';

void main() {
  final sampleEntries = [
    GoldPriceEntry(
      date: '26 Oct 2026',
      pavanPrice: 104480,
      gramPrice: 13060,
      changePavan: 480,
      changeGram: 60,
      changePercentage: 0.46,
      isToday: true,
      session: 'Evening',
    ),
    GoldPriceEntry(
      date: '25 Oct 2026',
      pavanPrice: 104000,
      gramPrice: 13000,
      changePavan: 0,
      changeGram: 0,
      changePercentage: 0.0,
      isYesterday: true,
    ),
  ];

  final sampleSummary = GoldMonthSummary(
    monthName: 'October 2026',
    latestEntry: sampleEntries.first,
    previousEntry: sampleEntries[1],
    monthHigh: 104480,
    monthHighDate: '26 Oct',
    monthLow: 101280,
    monthLowDate: '01 Oct',
    trend: 'Upward',
    entries: sampleEntries.reversed.toList(),
    overallMonthChangePavan: 3200,
    overallMonthChangePercent: 3.16,
    lastUpdated: DateTime(2026, 10, 26, 17, 0),
  );

  Widget createTestWidget({
    GoldMonthSummary? summary,
    bool isPavan = true,
    ValueChanged<bool>? onUnitChanged,
    VoidCallback? onOpenCalculator,
    Future<void> Function()? onRefresh,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: RatesView(
          summary: summary ?? sampleSummary,
          isPavan: isPavan,
          isLoading: false,
          onUnitChanged: onUnitChanged ?? (_) {},
          onRefresh: onRefresh ?? () async {},
          onOpenCalculator: onOpenCalculator ?? () {},
          onTestNotification: () async {},
        ),
      ),
    );
  }

  group('RatesView Widget Tests', () {
    testWidgets('renders market status banner, sentiment strip, and session peek', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.text('MARKET OPENS AT 10:00 AM • INTRA-DAY SYNC ACTIVE'),
        findsOneWidget,
      );
      expect(find.text('Market Bias: Bullish'), findsOneWidget);
      expect(find.text('MCX Bullion Parity Active'), findsOneWidget);
      expect(find.text('RECENT SESSION QUOTES'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Previous'), findsOneWidget);
    });

    testWidgets('renders calculator CTA and invokes onOpenCalculator on tap', (tester) async {
      bool calcTapped = false;
      await tester.pumpWidget(createTestWidget(
        onOpenCalculator: () => calcTapped = true,
      ));

      final calcBtn = find.text('Calculate');
      await tester.scrollUntilVisible(calcBtn, 300);
      expect(calcBtn, findsOneWidget);

      await tester.tap(calcBtn);
      await tester.pump();

      expect(calcTapped, isTrue);
    });

    testWidgets('renders unit toggle and triggers onUnitChanged', (tester) async {
      bool? selectedUnit;
      await tester.pumpWidget(createTestWidget(
        isPavan: true,
        onUnitChanged: (val) => selectedUnit = val,
      ));

      await tester.tap(find.text('1 Gram'));
      await tester.pump();

      expect(selectedUnit, isFalse);
    });
  });
}
