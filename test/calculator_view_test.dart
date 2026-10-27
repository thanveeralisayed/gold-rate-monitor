import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_rate_monitor/widgets/calculator_view.dart';

void main() {
  const double testGramRate = 10000.0;

  Widget createTestWidget({double gramRate = testGramRate}) {
    return MaterialApp(
      home: Scaffold(
        body: CalculatorView(currentGramRate: gramRate),
      ),
    );
  }

  group('CalculatorView Widget Tests', () {
    testWidgets('renders benchmark rates and default calculation', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('JEWELLERY ESTIMATOR'), findsOneWidget);
      expect(find.text('Purchase Calculator'), findsOneWidget);
      expect(find.text('₹10,000.00 / gram'), findsOneWidget);
      expect(find.text('₹80,000'), findsWidgets); // 1 Pavan banner & base price

      // Default: 8g, 8.5% VA, 3% GST
      // Base: 80,000
      // VA: 80,000 * 0.085 = 6,800
      // Subtotal: 86,800
      // GST: 86,800 * 0.03 = 2,604
      // Total: 89,404
      expect(find.text('₹6,800'), findsOneWidget);
      expect(find.text('₹2,604'), findsOneWidget);
      expect(find.text('₹89,404'), findsOneWidget);
    });

    testWidgets('stepper buttons increment and decrement weight', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Increment weight by 1g -> 9g
      final addBtn = find.byIcon(Icons.add_circle_outline);
      await tester.tap(addBtn);
      await tester.pump();

      // 9g * 10,000 = 90,000 base
      // VA (8.5%): 7,650
      // Subtotal: 97,650
      // GST (3%): 2,929.5 -> ₹2,930
      // Total: 100,579.5 -> ₹1,00,580
      expect(find.text('₹90,000'), findsOneWidget);
      expect(find.text('₹1,00,580'), findsOneWidget);

      // Decrement weight by 1g -> 8g
      final removeBtn = find.byIcon(Icons.remove_circle_outline);
      await tester.tap(removeBtn);
      await tester.pump();

      expect(find.text('₹80,000'), findsWidgets);
      expect(find.text('₹89,404'), findsOneWidget);
    });

    testWidgets('preset weight chips update calculation', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap 1g chip
      await tester.tap(find.text('1g'));
      await tester.pump();

      // 1g * 10,000 = 10,000
      // VA (8.5%): 850
      // Subtotal: 10,850
      // GST (3%): 325.5 -> ₹326
      // Total: 11,175.5 -> ₹11,176
      expect(find.text('₹10,000'), findsOneWidget);
      expect(find.text('₹850'), findsOneWidget);
      expect(find.text('₹11,176'), findsOneWidget);

      // Tap 16g (2 Pavans) chip
      await tester.tap(find.text('16g (2 Pavans)'));
      await tester.pump();

      // 16g * 10,000 = 160,000
      // VA (8.5%): 13,600
      // Subtotal: 173,600
      // GST (3%): 5,208
      // Total: 178,808
      expect(find.text('₹1,60,000'), findsOneWidget);
      expect(find.text('₹13,600'), findsOneWidget);
      expect(find.text('₹1,78,808'), findsOneWidget);
    });

    testWidgets('Stitch VA style preset chips update making charges', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap 5% Simple
      await tester.tap(find.text('5% Simple'));
      await tester.pump();

      // 8g * 10,000 = 80,000
      // VA (5%): 4,000
      // Subtotal: 84,000
      // GST (3%): 2,520
      // Total: 86,520
      expect(find.text('₹4,000'), findsOneWidget);
      expect(find.text('₹86,520'), findsOneWidget);

      // Tap 16% Bridal
      await tester.tap(find.text('16% Bridal'));
      await tester.pump();

      // 8g * 10,000 = 80,000
      // VA (16%): 12,800
      // Subtotal: 92,800
      // GST (3%): 2,784
      // Total: 95,584
      expect(find.text('₹12,800'), findsOneWidget);
      expect(find.text('₹95,584'), findsOneWidget);
    });

    testWidgets('toggling 3% GST switch zeroes out tax and adjusts grand total', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initial GST is enabled (Total: 89,404)
      expect(find.text('₹89,404'), findsOneWidget);

      // Toggle off GST switch
      final gstSwitch = find.byType(Switch);
      await tester.tap(gstSwitch);
      await tester.pump();

      // Total without GST = Subtotal: 86,800
      expect(find.text('₹0'), findsOneWidget);
      expect(find.text('₹86,800'), findsWidgets);
    });
  });
}
