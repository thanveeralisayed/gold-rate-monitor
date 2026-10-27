import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_rate_monitor/models/gold_rate_model.dart';
import 'package:gold_rate_monitor/widgets/history_view.dart';

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
    GoldPriceEntry(
      date: '01 Oct 2026',
      pavanPrice: 101280,
      gramPrice: 12660,
      changePavan: -160,
      changeGram: -20,
      changePercentage: -0.16,
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
    required GoldMonthSummary summary,
    bool isPavan = true,
    ValueChanged<bool>? onUnitChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HistoryView(
          summary: summary,
          isPavan: isPavan,
          onUnitChanged: onUnitChanged ?? (_) {},
        ),
      ),
    );
  }

  group('HistoryView Widget Tests', () {
    testWidgets('renders archival header with month ledger and session count', (tester) async {
      await tester.pumpWidget(createTestWidget(summary: sampleSummary));

      expect(find.text('RATE ARCHIVE'), findsOneWidget);
      expect(find.text('October 2026 Ledger'), findsOneWidget);
      expect(find.text('3 Sessions'), findsOneWidget);
      expect(find.text('Pavan'), findsOneWidget);
      expect(find.text('Gram'), findsOneWidget);
    });

    testWidgets('renders 3-column Bento metrics correctly in Pavan unit', (tester) async {
      await tester.pumpWidget(createTestWidget(summary: sampleSummary, isPavan: true));

      expect(find.text('MONTH HIGH'), findsOneWidget);
      expect(find.text('₹1,04,480'), findsWidgets);
      expect(find.text('MONTH LOW'), findsOneWidget);
      expect(find.text('₹1,01,280'), findsWidgets);
      expect(find.text('NET MTD'), findsOneWidget);
      expect(find.text('+₹3,200'), findsOneWidget);
      expect(find.text('+3.16%'), findsOneWidget);
    });

    testWidgets('renders 3-column Bento metrics correctly in Gram unit', (tester) async {
      await tester.pumpWidget(createTestWidget(summary: sampleSummary, isPavan: false));

      expect(find.text('MONTH HIGH'), findsOneWidget);
      expect(find.text('₹13,060.00'), findsWidgets);
      expect(find.text('MONTH LOW'), findsOneWidget);
      expect(find.text('₹12,660.00'), findsWidgets);
      expect(find.text('NET MTD'), findsOneWidget);
      expect(find.text('+₹400.00'), findsOneWidget);
    });

    testWidgets('renders monthly trading spread bar', (tester) async {
      await tester.pumpWidget(createTestWidget(summary: sampleSummary));

      expect(find.text('MONTHLY TRADING SPREAD'), findsOneWidget);
      expect(find.text('Spread: ₹3,200'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders ledger entries with dates, session tags and net change badges', (tester) async {
      await tester.pumpWidget(createTestWidget(summary: sampleSummary));

      expect(find.text('SESSION LEDGER'), findsOneWidget);
      expect(find.text('26 Oct 2026'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
      expect(find.text('25 Oct 2026'), findsOneWidget);
      expect(find.text('01 Oct 2026'), findsOneWidget);
      expect(find.text('+₹480'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('-₹160'), findsOneWidget);
    });

    testWidgets('triggers onUnitChanged callback when unit tab is tapped', (tester) async {
      bool? selectedUnit;
      await tester.pumpWidget(createTestWidget(
        summary: sampleSummary,
        isPavan: true,
        onUnitChanged: (val) => selectedUnit = val,
      ));

      await tester.tap(find.text('Gram'));
      await tester.pump();

      expect(selectedUnit, isFalse);
    });
  });
}
