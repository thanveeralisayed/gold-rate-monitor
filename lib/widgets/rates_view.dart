import 'package:flutter/material.dart';
import '../models/gold_rate_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'gold_header.dart';
import 'gold_hero_card.dart';
import 'gold_trend_chart.dart';

class RatesView extends StatelessWidget {
  final GoldMonthSummary summary;
  final bool isPavan;
  final bool isLoading;
  final ValueChanged<bool> onUnitChanged;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenCalculator;
  final Future<void> Function() onTestNotification;

  const RatesView({
    super.key,
    required this.summary,
    required this.isPavan,
    required this.isLoading,
    required this.onUnitChanged,
    required this.onRefresh,
    required this.onOpenCalculator,
    required this.onTestNotification,
  });

  @override
  Widget build(BuildContext context) {
    final latest = summary.latestEntry;
    final previous = summary.previousEntry;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.goldPrimary,
      backgroundColor: AppTheme.surfaceElevated,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            GoldHeader(
              isLoading: isLoading,
              onRefresh: onRefresh,
              onOpenCalculator: onOpenCalculator,
              onTestNotification: onTestNotification,
            ),
            const SizedBox(height: 16),

            // Stitch Market Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.greenRate,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'MARKET OPENS AT 10:00 AM • INTRA-DAY SYNC ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const Text(
                    '22K 916',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.goldLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hero Card
            GoldHeroCard(
              summary: summary,
              isPavan: isPavan,
              onUnitChanged: onUnitChanged,
            ),
            const SizedBox(height: 18),

            // MCX Futures & Market Sentiment Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.show_chart_rounded, size: 16, color: AppTheme.goldAccent),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Market Bias: ${summary.trend.toLowerCase() == 'downward' ? 'Bearish' : summary.trend.toLowerCase() == 'upward' ? 'Bullish' : 'Neutral'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MCX Bullion Parity Active',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Interactive Trend Graph
            GoldTrendChart(
              entries: summary.entries,
              isPavan: isPavan,
            ),
            const SizedBox(height: 18),

            // Recent Sessions Peek
            if (previous != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RECENT SESSION QUOTES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Today's latest
                        Expanded(
                          child: _buildSessionPeekItem(
                            title: latest.displayTitle,
                            price: CurrencyFormatter.format(
                              isPavan ? latest.pavanPrice : latest.gramPrice,
                              decimal: !isPavan,
                            ),
                            tag: 'Current',
                            tagColor: AppTheme.goldAccent,
                          ),
                        ),
                        Container(width: 1, height: 36, color: AppTheme.surfaceBorder),
                        // Previous session
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: _buildSessionPeekItem(
                              title: previous.displayTitle,
                              price: CurrencyFormatter.format(
                                isPavan ? previous.pavanPrice : previous.gramPrice,
                                decimal: !isPavan,
                              ),
                              tag: 'Previous',
                              tagColor: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Jewellery Cost Calculator CTA Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E283D), Color(0xFF131B2B)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.goldPrimary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.goldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: AppTheme.goldAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimate Jewellery Cost',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Calculate making charges (VA) & 3% GST',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onOpenCalculator,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldPrimary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Calculate',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick Bullion Info Callout
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.goldAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Standard 1 Pavan = 8 Grams of 22 Karat (916) Gold. Rates reflect daily Kerala bullion market quotes.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: AppTheme.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Data parsed from KeralaGold.com • Daily Prices',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: ${summary.lastUpdated.hour.toString().padLeft(2, '0')}:${summary.lastUpdated.minute.toString().padLeft(2, '0')} • Synced with 10 AM & 5 PM windows',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionPeekItem({
    required String title,
    required String price,
    required String tag,
    required Color tagColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: tagColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
