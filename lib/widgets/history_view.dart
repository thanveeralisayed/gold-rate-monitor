import 'package:flutter/material.dart';
import '../models/gold_rate_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class HistoryView extends StatelessWidget {
  final GoldMonthSummary summary;
  final bool isPavan;
  final ValueChanged<bool> onUnitChanged;
  final Future<void> Function()? onRefresh;

  const HistoryView({
    super.key,
    required this.summary,
    required this.isPavan,
    required this.onUnitChanged,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final highPrice = isPavan ? summary.monthHigh : (summary.monthHigh / 8.0);
    final lowPrice = isPavan ? summary.monthLow : (summary.monthLow / 8.0);
    final netChange = isPavan
        ? summary.overallMonthChangePavan
        : (summary.overallMonthChangePavan / 8.0);
    final currentPrice = isPavan
        ? summary.latestEntry.pavanPrice
        : summary.latestEntry.gramPrice;

    // Calculate position in month range (0.0 to 1.0)
    final rangeSpan = highPrice - lowPrice;
    final rangeProgress = rangeSpan > 0
        ? ((currentPrice - lowPrice) / rangeSpan).clamp(0.0, 1.0)
        : 0.5;

    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Archival Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.goldPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.goldPrimary.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'RATE ARCHIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: AppTheme.goldLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${summary.entries.length} Sessions',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${summary.monthName} Ledger',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Unit Selector Segmented Pill
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUnitButton('Pavan', isPavan, () => onUnitChanged(true)),
                    _buildUnitButton('Gram', !isPavan, () => onUnitChanged(false)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3-Column Bento Metrics Grid
          Row(
            children: [
              // High Card
              Expanded(
                child: _buildBentoCard(
                  title: 'MONTH HIGH',
                  value: CurrencyFormatter.format(highPrice, decimal: !isPavan),
                  accentColor: AppTheme.goldAccent,
                  badgeText: summary.monthHighDate,
                  icon: Icons.north_east_rounded,
                ),
              ),
              const SizedBox(width: 10),

              // Low Card
              Expanded(
                child: _buildBentoCard(
                  title: 'MONTH LOW',
                  value: CurrencyFormatter.format(lowPrice, decimal: !isPavan),
                  accentColor: AppTheme.greenSecondary,
                  badgeText: summary.monthLowDate,
                  icon: Icons.south_east_rounded,
                ),
              ),
              const SizedBox(width: 10),

              // Net MTD Card
              Expanded(
                child: _buildBentoCard(
                  title: 'NET MTD',
                  value: CurrencyFormatter.formatChange(netChange, isGram: !isPavan),
                  accentColor: netChange >= 0 ? AppTheme.greenRate : AppTheme.redRate,
                  badgeText: CurrencyFormatter.formatPercent(summary.overallMonthChangePercent),
                  icon: netChange >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Monthly Range Bar Card
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MONTHLY TRADING SPREAD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      'Spread: ${CurrencyFormatter.format(rangeSpan, decimal: !isPavan)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: rangeProgress,
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceLight.withValues(alpha: 0.4),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.goldPrimary),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Low: ${CurrencyFormatter.format(lowPrice, decimal: !isPavan)}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                    Text(
                      'Current: ${CurrencyFormatter.format(currentPrice, decimal: !isPavan)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.goldLight,
                      ),
                    ),
                    Text(
                      'High: ${CurrencyFormatter.format(highPrice, decimal: !isPavan)}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Day-by-Day Historical Records Container
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SESSION LEDGER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${summary.entriesNewestFirst.length} verified quotes',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: summary.entriesNewestFirst.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Color(0xFF1A2234),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final entry = summary.entriesNewestFirst[index];
                    final price = isPavan ? entry.pavanPrice : entry.gramPrice;
                    final change = isPavan ? entry.changePavan : entry.changeGram;
                    final isNegative = change < 0;
                    final isZero = change == 0;

                    final changeColor = isZero
                        ? AppTheme.textMuted
                        : isNegative
                            ? AppTheme.redRate
                            : AppTheme.greenRate;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Row(
                        children: [
                          // Date & Session
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      entry.date,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: entry.isToday ? FontWeight.w800 : FontWeight.w600,
                                        color: entry.isToday ? AppTheme.goldLight : AppTheme.textPrimary,
                                      ),
                                    ),
                                    if (entry.session != null) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceContainerHigh,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          entry.session!,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.goldAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entry.isToday
                                      ? 'Today'
                                      : entry.isYesterday
                                          ? 'Yesterday'
                                          : 'Session',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Price Column
                          Expanded(
                            flex: 4,
                            child: Text(
                              CurrencyFormatter.format(price, decimal: !isPavan),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Net Change Badge
                          SizedBox(
                            width: 82,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: isZero
                                    ? AppTheme.surfaceLight.withValues(alpha: 0.25)
                                    : isNegative
                                        ? AppTheme.redBackground
                                        : AppTheme.greenBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isZero) ...[
                                    Icon(
                                      isNegative ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                      size: 11,
                                      color: changeColor,
                                    ),
                                    const SizedBox(width: 2),
                                  ],
                                  Flexible(
                                    child: Text(
                                      isZero ? '0' : CurrencyFormatter.formatChange(change, isGram: !isPavan),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: changeColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppTheme.goldPrimary,
        backgroundColor: AppTheme.surfaceElevated,
        child: content,
      );
    }
    return content;
  }

  Widget _buildUnitButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.goldPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.black : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String value,
    required Color accentColor,
    required String badgeText,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 12, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
