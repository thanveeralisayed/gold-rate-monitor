import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_rate_monitor/services/gold_scraper_service.dart';
import 'package:gold_rate_monitor/theme/app_theme.dart';
import 'package:gold_rate_monitor/widgets/daily_history_list.dart';
import 'package:gold_rate_monitor/widgets/gold_calculator_sheet.dart';
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
}
