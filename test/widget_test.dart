import 'package:flutter_test/flutter_test.dart';
import 'package:gold_rate_monitor/main.dart';

void main() {
  testWidgets('GoldRateApp basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GoldRateApp());
    expect(find.byType(GoldRateApp), findsOneWidget);
  });
}
