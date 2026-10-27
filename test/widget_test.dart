import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_rate_monitor/models/gold_rate_model.dart';
import 'package:gold_rate_monitor/services/gold_scraper_service.dart';
import 'package:gold_rate_monitor/theme/app_theme.dart';
import 'package:gold_rate_monitor/widgets/daily_history_list.dart';
import 'package:gold_rate_monitor/widgets/gold_calculator_sheet.dart';
import 'package:gold_rate_monitor/widgets/gold_header.dart';
import 'package:gold_rate_monitor/widgets/gold_hero_card.dart';
import 'package:gold_rate_monitor/widgets/gold_trend_chart.dart';

void main() {
  final summary = GoldScraperService.getFallbackData();

  Widget wrapWithTheme(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  testWidgets('GoldHeroCard renders prices and handles unit toggling', (tester) async {
    bool isPavan = true;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => wrapWithTheme(
          GoldHeroCard(
            summary: summary,
            isPavan: isPavan,
            onUnitChanged: (val) {
              setState(() {
                isPavan = val;
              });
            },
          ),
        ),
      ),
    );

    // Initial state: 1 Pavan price (1,04,480)
    expect(find.textContaining('1,04,480'), findsWidgets);
    expect(find.text('1 Pavan'), findsOneWidget);
    expect(find.text('1 Gram'), findsOneWidget);

    // Tap '1 Gram' unit toggle
    await tester.tap(find.text('1 Gram'));
    await tester.pumpAndSettle();

    // After toggle: 1 Gram price (~13,060)
    expect(find.textContaining('13,060'), findsWidgets);
  });

  testWidgets('GoldTrendChart renders correctly with period options', (tester) async {
    await tester.pumpWidget(
      wrapWithTheme(
        GoldTrendChart(
          entries: summary.entries,
          isPavan: true,
        ),
      ),
    );

    expect(find.text('PRICE MOVEMENT GRAPH'), findsOneWidget);
    expect(find.text('7D'), findsOneWidget);
    expect(find.text('14D'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);

    // Switch period to 7D
    await tester.tap(find.text('7D'));
    await tester.pumpAndSettle();

    // Switch to 14D
    await tester.tap(find.text('14D'));
    await tester.pumpAndSettle();
  });

  testWidgets('DailyHistoryList renders historical entries', (tester) async {
    await tester.pumpWidget(
      wrapWithTheme(
        DailyHistoryList(
          entriesNewestFirst: summary.entriesNewestFirst,
          isPavan: true,
        ),
      ),
    );

    expect(find.text('DAY-BY-DAY RATE HISTORY'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YESTERDAY'), findsOneWidget);
  });

  testWidgets('GoldCalculatorSheet calculates prices and handles user input', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: GoldCalculatorSheet(
            currentGramRate: 13060.0,
          ),
        ),
      ),
    );

    // Default weight is 8g (1 Pavan)
    expect(find.text('Jewellery Price Estimator'), findsOneWidget);
    expect(find.text('8'), findsOneWidget); // Default weight input

    // Base price = 8 * 13,060 = ₹1,04,480
    expect(find.textContaining('1,04,480'), findsWidgets);

    // Test changing preset weight chip to 1 Gram
    await tester.tap(find.text('1 Gram'));
    await tester.pumpAndSettle();

    // Base price becomes 1 * 13060 = ₹13,060
    expect(find.textContaining('13,060'), findsWidgets);
  });

  testWidgets('GoldHeader triggers refresh, calculator, and notification callbacks', (tester) async {
    bool refreshed = false;
    bool calculatorOpened = false;
    bool notificationTested = false;

    await tester.pumpWidget(
      wrapWithTheme(
        GoldHeader(
          isLoading: false,
          onRefresh: () => refreshed = true,
          onOpenCalculator: () => calculatorOpened = true,
          onTestNotification: () => notificationTested = true,
        ),
      ),
    );

    expect(find.text('Kerala Gold Rate'), findsOneWidget);
    expect(find.text('Live 22K Market Tracker'), findsOneWidget);

    // Tap notification button
    await tester.tap(find.byIcon(Icons.notifications_active_outlined));
    expect(notificationTested, isTrue);

    // Tap calculator button
    await tester.tap(find.byIcon(Icons.calculate_outlined));
    expect(calculatorOpened, isTrue);

    // Tap refresh button
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    expect(refreshed, isTrue);
  });

  testWidgets('GoldHeroCard renders zero change as "Unchanged today"', (tester) async {
    final zeroChangeSummary = GoldMonthSummary(
      monthName: 'October 2026',
      latestEntry: GoldPriceEntry(
        date: '24-Oct-26',
        isToday: true,
        pavanPrice: 104480,
        gramPrice: 13060.0,
        changePavan: 0,
        changeGram: 0.0,
        changePercentage: 0.0,
      ),
      monthHigh: 111040,
      monthHighDate: '10th Oct',
      monthLow: 104480,
      monthLowDate: '23rd Oct',
      trend: 'Stable',
      entries: [],
      overallMonthChangePavan: 0,
      overallMonthChangePercent: 0.0,
      lastUpdated: DateTime.now(),
    );

    await tester.pumpWidget(
      wrapWithTheme(
        GoldHeroCard(
          summary: zeroChangeSummary,
          isPavan: true,
          onUnitChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Unchanged today'), findsOneWidget);
    expect(find.text('Trend: Stable'), findsOneWidget);
  });

  testWidgets('GoldCalculatorSheet toggles GST and updates grand total accordingly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GoldCalculatorSheet(
            currentGramRate: 10000.0,
          ),
        ),
      ),
    );

    // Default with 8g @ 10,000/g: Base = 80,000. Making charge = 8% = 6,400. Subtotal = 86,400. GST (3%) = 2,592. Total = 88,992.
    expect(find.text('GST (3%)'), findsOneWidget);
    expect(find.textContaining('88,992'), findsOneWidget);

    // Toggle GST switch off
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // After GST off: Grand Total = 86,400
    expect(find.textContaining('86,400'), findsOneWidget);
    expect(find.text('GST (3%)'), findsNothing);
  });

  testWidgets('GoldCalculatorSheet updates calculations when custom weight text is entered', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GoldCalculatorSheet(
            currentGramRate: 10000.0,
          ),
        ),
      ),
    );

    // Clear and enter '10' grams
    final textField = find.byType(TextField);
    await tester.enterText(textField, '10');
    await tester.pumpAndSettle();

    // Base = 10 * 10000 = 1,00,000. Making charge 8% = 8,000. Subtotal = 1,08,000. GST 3% = 3,240. Total = 1,11,240.
    expect(find.textContaining('1,00,000'), findsWidgets);
    expect(find.textContaining('1,11,240'), findsOneWidget);
  });
}
