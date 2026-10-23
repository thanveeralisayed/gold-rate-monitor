import 'package:flutter_test/flutter_test.dart';
import 'package:gold_rate_monitor/services/gold_scraper_service.dart';
import 'package:gold_rate_monitor/utils/formatters.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats rupee integers correctly', () {
      final formatted = CurrencyFormatter.format(104480);
      expect(formatted.contains('1,04,480'), isTrue);
    });

    test('formats rupee decimals correctly', () {
      final formatted = CurrencyFormatter.format(13060.50, decimal: true);
      expect(formatted.contains('13,060.50'), isTrue);
    });

    test('formats negative change with minus sign', () {
      final formatted = CurrencyFormatter.formatChange(-1400);
      expect(formatted.contains('-') && formatted.contains('1,400'), isTrue);
    });

    test('formats positive change with plus prefix', () {
      final formatted = CurrencyFormatter.formatChange(800);
      expect(formatted.startsWith('+'), isTrue);
      expect(formatted.contains('800'), isTrue);
    });

    test('formats percentages correctly', () {
      expect(CurrencyFormatter.formatPercent(-1.321), '-1.32%');
      expect(CurrencyFormatter.formatPercent(0.754), '+0.75%');
    });
  });

  group('GoldScraperService & Model Tests', () {
    test('fallback dataset provides valid October 2026 data', () {
      final summary = GoldScraperService.getFallbackData();

      expect(summary.monthName, 'October 2026');
      expect(summary.entries.isNotEmpty, isTrue);
      expect(summary.entries.length, greaterThanOrEqualTo(20));

      final latest = summary.latestEntry;
      expect(latest.pavanPrice, 104480);
      expect(latest.gramPrice, 104480 / 8.0);
      expect(latest.isToday, isTrue);

      expect(summary.monthHigh, 111040);
      expect(summary.monthLow, 104480);
      expect(summary.trend, 'Downward');
    });

    test('HTML parser correctly extracts tables and trends', () {
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

      final service = GoldScraperService();
      final summary = service.parseHtml(sampleHtml);

      expect(summary.entries.length, 3);
      expect(summary.entries[0].pavanPrice, 109440);
      expect(summary.entries[1].pavanPrice, 110200);
      expect(summary.entries[1].changePavan, 760); // 110200 - 109440
      expect(summary.latestEntry.pavanPrice, 104480);
      expect(summary.latestEntry.isToday, isTrue);
      expect(summary.trend, 'Downward');
    });
  });
}
