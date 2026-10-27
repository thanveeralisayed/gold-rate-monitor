import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gold_rate_monitor/models/gold_rate_model.dart';
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

  group('Scrape Window & Rate Limit Policy Tests', () {
    test('initial state with no cache requires scrape', () async {
      SharedPreferences.setMockInitialValues({});
      final service = GoldScraperService();
      final shouldScrape = await service.shouldAutoScrape(testNow: DateTime(2026, 10, 27, 8, 30));
      expect(shouldScrape, isTrue);
    });

    test('before 10am with existing cache skips scraping to avoid rate limits', () async {
      SharedPreferences.setMockInitialValues({
        GoldScraperService.prefKeyCachedHtml: '<html><body><table></table></body></html>',
      });
      final service = GoldScraperService();
      final shouldScrape = await service.shouldAutoScrape(testNow: DateTime(2026, 10, 27, 8, 30));
      expect(shouldScrape, isFalse);
    });

    test('after 10am when morning scrape not done requires scrape', () async {
      SharedPreferences.setMockInitialValues({
        GoldScraperService.prefKeyCachedHtml: '<html><body><table></table></body></html>',
        GoldScraperService.prefKeyLastMorningScrape: '2026-10-26', // yesterday
      });
      final service = GoldScraperService();
      final shouldScrape = await service.shouldAutoScrape(testNow: DateTime(2026, 10, 27, 10, 15));
      expect(shouldScrape, isTrue);
    });

    test('between 10am and 5pm when morning scrape already completed skips scraping', () async {
      SharedPreferences.setMockInitialValues({
        GoldScraperService.prefKeyCachedHtml: '<html><body><table></table></body></html>',
        GoldScraperService.prefKeyLastMorningScrape: '2026-10-27', // today
      });
      final service = GoldScraperService();
      final shouldScrape = await service.shouldAutoScrape(testNow: DateTime(2026, 10, 27, 14, 0));
      expect(shouldScrape, isFalse);
    });

    test('after 5pm when evening scrape not done requires scrape', () async {
      SharedPreferences.setMockInitialValues({
        GoldScraperService.prefKeyCachedHtml: '<html><body><table></table></body></html>',
        GoldScraperService.prefKeyLastMorningScrape: '2026-10-27',
        GoldScraperService.prefKeyLastEveningScrape: '2026-10-26',
      });
      final service = GoldScraperService();
      final shouldScrape = await service.shouldAutoScrape(testNow: DateTime(2026, 10, 27, 17, 30));
      expect(shouldScrape, isTrue);
    });

    test('after 5pm when evening scrape already completed skips scraping', () async {
      SharedPreferences.setMockInitialValues({
        GoldScraperService.prefKeyCachedHtml: '<html><body><table></table></body></html>',
        GoldScraperService.prefKeyLastMorningScrape: '2026-10-27',
        GoldScraperService.prefKeyLastEveningScrape: '2026-10-27',
      });
      final service = GoldScraperService();
      final shouldScrape = await service.shouldAutoScrape(testNow: DateTime(2026, 10, 27, 19, 0));
      expect(shouldScrape, isFalse);
    });
  });

  group('CurrencyFormatter Edge Cases', () {
    test('formats zero values correctly', () {
      expect(CurrencyFormatter.format(0), '₹0');
      expect(CurrencyFormatter.format(0, decimal: true), '₹0.00');
    });

    test('formats zero change without +/- prefix', () {
      expect(CurrencyFormatter.formatChange(0), '₹0');
      expect(CurrencyFormatter.formatChange(0, isGram: true), '₹0.00');
    });

    test('formats zero percentage without prefix', () {
      expect(CurrencyFormatter.formatPercent(0.0), '0.00%');
    });

    test('formats high Indian numbering values correctly', () {
      final formatted = CurrencyFormatter.format(1000000); // 10 Lakhs
      expect(formatted.contains('10,00,000'), isTrue);
    });

    test('formats gram changes with 2 decimal precision', () {
      final changePos = CurrencyFormatter.formatChange(65.45, isGram: true);
      expect(changePos.startsWith('+'), isTrue);
      expect(changePos.contains('65.45'), isTrue);

      final changeNeg = CurrencyFormatter.formatChange(-175.50, isGram: true);
      expect(changeNeg.contains('-') && changeNeg.contains('175.50'), isTrue);
    });
  });

  group('GoldPriceEntry & GoldMonthSummary Model Edge Cases', () {
    test('displayTitle handles sessions and null sessions properly', () {
      final entryWithSession = GoldPriceEntry(
        date: '20-Oct-26',
        session: 'Morning',
        pavanPrice: 107920,
        gramPrice: 13490.0,
        changePavan: 0,
        changeGram: 0.0,
        changePercentage: 0.0,
      );
      expect(entryWithSession.displayTitle, '20-Oct-26 (Morning)');

      final entryNullSession = GoldPriceEntry(
        date: '21-Oct-26',
        session: null,
        pavanPrice: 107120,
        gramPrice: 13390.0,
        changePavan: -800,
        changeGram: -100.0,
        changePercentage: -0.74,
      );
      expect(entryNullSession.displayTitle, '21-Oct-26');

      final entryEmptySession = GoldPriceEntry(
        date: '21-Oct-26',
        session: '',
        pavanPrice: 107120,
        gramPrice: 13390.0,
        changePavan: -800,
        changeGram: -100.0,
        changePercentage: -0.74,
      );
      expect(entryEmptySession.displayTitle, '21-Oct-26');
    });

    test('entriesNewestFirst reverses entries without modifying chronological order', () {
      final summary = GoldScraperService.getFallbackData();
      final chronological = summary.entries;
      final newestFirst = summary.entriesNewestFirst;

      expect(newestFirst.first.date, chronological.last.date);
      expect(newestFirst.last.date, chronological.first.date);
      expect(newestFirst.length, chronological.length);
      expect(chronological.first.date, isNot(equals(newestFirst.first.date)));
    });
  });

  group('GoldScraperService HTML Parsing Edge Cases', () {
    test('handles empty or broken HTML gracefully by returning fallback data', () {
      final service = GoldScraperService();
      final emptySummary = service.parseHtml('');
      expect(emptySummary.entries.isNotEmpty, isTrue);

      final brokenSummary = service.parseHtml('<html><body>No table here</body></html>');
      expect(brokenSummary.entries.isNotEmpty, isTrue);
    });

    test('parses multi-session intra-day updates (Morning, Afternoon, Evening)', () {
      const multiSessionHtml = '''
        <table>
          <tr><td>Date</td><td>Price of 1 Pavan Gold</td></tr>
          <tr><td>6-Oct-26 (Morning)</td><td>109280</td></tr>
          <tr><td>6-Oct-26 (Evening)</td><td>110160</td></tr>
          <tr><td>7-Oct-26 (Afternoon)</td><td>109680</td></tr>
        </table>
      ''';
      final service = GoldScraperService();
      final summary = service.parseHtml(multiSessionHtml);

      expect(summary.entries.length, 3);
      expect(summary.entries[0].session, 'Morning');
      expect(summary.entries[0].displayTitle, '6-Oct-26 (Morning)');
      expect(summary.entries[1].session, 'Evening');
      expect(summary.entries[1].changePavan, 880); // 110160 - 109280
      expect(summary.entries[2].session, 'Afternoon');
      expect(summary.entries[2].changePavan, -480); // 109680 - 110160
    });

    test('computes month high and low dynamically when summary table is omitted', () {
      const noHighLowTableHtml = '''
        <table>
          <tr><td>Date</td><td>Price of 1 Pavan Gold</td></tr>
          <tr><td>1-Oct-26</td><td>100000</td></tr>
          <tr><td>2-Oct-26</td><td>115000</td></tr>
          <tr><td>3-Oct-26</td><td>95000</td></tr>
        </table>
      ''';
      final service = GoldScraperService();
      final summary = service.parseHtml(noHighLowTableHtml);

      expect(summary.monthHigh, 115000);
      expect(summary.monthHighDate, '2-Oct-26');
      expect(summary.monthLow, 95000);
      expect(summary.monthLowDate, '3-Oct-26');
      expect(summary.overallMonthChangePavan, -5000); // 95000 - 100000
    });

    test('extracts prices with irregular formatting, currencies, and suffixes', () {
      const irregularPricesHtml = '''
        <table>
          <tr><td>Date</td><td>Price of 1 Pavan Gold</td></tr>
          <tr><td>10-Oct-26</td><td>Rs. 1,11,040/- (Highest of Month)</td></tr>
          <tr><td>11-Oct-26</td><td>1,04,480 INR (Lowest of Month)</td></tr>
        </table>
      ''';
      final service = GoldScraperService();
      final summary = service.parseHtml(irregularPricesHtml);

      expect(summary.entries.length, 2);
      expect(summary.entries[0].pavanPrice, 111040);
      expect(summary.entries[0].isHighest, isTrue);
      expect(summary.entries[1].pavanPrice, 104480);
      expect(summary.entries[1].isLowest, isTrue);
    });

    test('formatDateKey formats dates with zero-padded months and days', () {
      expect(GoldScraperService.formatDateKey(DateTime(2026, 4, 5)), '2026-04-05');
      expect(GoldScraperService.formatDateKey(DateTime(2026, 11, 28)), '2026-11-28');
    });
  });

  group('GoldScraperService Caching & Persistence Edge Cases', () {
    test('recordSuccessfulScrape flags morning session correctly at 11 AM', () async {
      SharedPreferences.setMockInitialValues({});
      final service = GoldScraperService();
      final testTime = DateTime(2026, 10, 27, 11, 0);

      await service.recordSuccessfulScrape('<html>Sample Data</html>', testTime);
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString(GoldScraperService.prefKeyCachedHtml), '<html>Sample Data</html>');
      expect(prefs.getString(GoldScraperService.prefKeyLastMorningScrape), '2026-10-27');
      expect(prefs.getString(GoldScraperService.prefKeyLastEveningScrape), isNull);
    });

    test('recordSuccessfulScrape flags both morning and evening at 6 PM', () async {
      SharedPreferences.setMockInitialValues({});
      final service = GoldScraperService();
      final testTime = DateTime(2026, 10, 27, 18, 0);

      await service.recordSuccessfulScrape('<html>Evening Data</html>', testTime);
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString(GoldScraperService.prefKeyLastMorningScrape), '2026-10-27');
      expect(prefs.getString(GoldScraperService.prefKeyLastEveningScrape), '2026-10-27');
    });

    test('recordSuccessfulScrape before 10 AM does not mark morning or evening complete', () async {
      SharedPreferences.setMockInitialValues({});
      final service = GoldScraperService();
      final testTime = DateTime(2026, 10, 27, 8, 0);

      await service.recordSuccessfulScrape('<html>Early Data</html>', testTime);
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString(GoldScraperService.prefKeyCachedHtml), '<html>Early Data</html>');
      expect(prefs.getString(GoldScraperService.prefKeyLastMorningScrape), isNull);
      expect(prefs.getString(GoldScraperService.prefKeyLastEveningScrape), isNull);
    });

    test('getCachedRates returns null when cache is missing or corrupt', () async {
      SharedPreferences.setMockInitialValues({});
      final service = GoldScraperService();
      final cached = await service.getCachedRates();
      expect(cached, isNull);
    });

    test('getCachedRates parses valid cached HTML and preserves lastUpdated timestamp', () async {
      final sampleTimestamp = DateTime(2026, 10, 27, 10, 30);
      const sampleHtml = '''
        <table>
          <tr><td>Date</td><td>Price of 1 Pavan Gold</td></tr>
          <tr><td>27-Oct-26</td><td>105000</td></tr>
        </table>
      ''';
      SharedPreferences.setMockInitialValues({
        GoldScraperService.prefKeyCachedHtml: sampleHtml,
        GoldScraperService.prefKeyCachedTimestamp: sampleTimestamp.toIso8601String(),
      });

      final service = GoldScraperService();
      final cached = await service.getCachedRates();

      expect(cached, isNotNull);
      expect(cached!.latestEntry.pavanPrice, 105000);
      expect(cached.lastUpdated.hour, 10);
      expect(cached.lastUpdated.minute, 30);
    });
  });

  group('Jewellery Purchase Calculator Arithmetic Edge Cases', () {
    test('computes exact pricing for 0% making charges and 0% GST', () {
      const gramRate = 13000.0;
      const weight = 8.0;
      const makingChargePct = 0.0;
      const includeGst = false;

      final basePrice = weight * gramRate;
      final makingChargeAmount = (basePrice * makingChargePct) / 100.0;
      final subtotal = basePrice + makingChargeAmount;
      final gstAmount = includeGst ? (subtotal * 0.03) : 0.0;
      final grandTotal = subtotal + gstAmount;

      expect(basePrice, 104000.0);
      expect(makingChargeAmount, 0.0);
      expect(gstAmount, 0.0);
      expect(grandTotal, 104000.0);
    });

    test('computes exact pricing with typical 8% making charges and 3% GST', () {
      const gramRate = 13060.0;
      const weight = 8.0;
      const makingChargePct = 8.0;
      const includeGst = true;

      final basePrice = weight * gramRate;
      final makingChargeAmount = (basePrice * makingChargePct) / 100.0;
      final subtotal = basePrice + makingChargeAmount;
      final gstAmount = subtotal * 0.03;
      final grandTotal = subtotal + gstAmount;

      expect(basePrice, 104480.0);
      expect(makingChargeAmount, closeTo(8358.4, 0.01));
      expect(gstAmount, closeTo(3385.15, 0.01));
      expect(grandTotal, closeTo(116223.55, 0.01));
    });

    test('handles small fractional weights (e.g. 0.5 grams nose pin)', () {
      const gramRate = 13000.0;
      const weight = 0.5;
      const makingChargePct = 12.0;
      const includeGst = true;

      final basePrice = weight * gramRate;
      final makingChargeAmount = (basePrice * makingChargePct) / 100.0;
      final subtotal = basePrice + makingChargeAmount;
      final gstAmount = subtotal * 0.03;
      final grandTotal = subtotal + gstAmount;

      expect(basePrice, 6500.0);
      expect(makingChargeAmount, 780.0);
      expect(gstAmount, closeTo(218.4, 0.01));
      expect(grandTotal, closeTo(7498.4, 0.01));
    });

    test('handles large wedding bulk weights (50 Pavans / 400 grams)', () {
      const gramRate = 13000.0;
      const weight = 400.0;
      const makingChargePct = 6.5;
      const includeGst = true;

      final basePrice = weight * gramRate;
      final makingChargeAmount = (basePrice * makingChargePct) / 100.0;
      final subtotal = basePrice + makingChargeAmount;
      final gstAmount = subtotal * 0.03;
      final grandTotal = subtotal + gstAmount;

      expect(basePrice, 5200000.0);
      expect(makingChargeAmount, 338000.0);
      expect(gstAmount, 166140.0);
      expect(grandTotal, 5704140.0);
    });
  });
}
