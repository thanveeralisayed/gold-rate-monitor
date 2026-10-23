import 'package:flutter/material.dart';
import '../models/gold_rate_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class DailyHistoryList extends StatelessWidget {
  final List<GoldPriceEntry> entriesNewestFirst;
  final bool isPavan;

  const DailyHistoryList({
    super.key,
    required this.entriesNewestFirst,
    required this.isPavan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F293D)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DAY-BY-DAY RATE HISTORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${entriesNewestFirst.length} records this month',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entriesNewestFirst.length,
            separatorBuilder: (context, index) => const Divider(
              color: Color(0xFF1A2234),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final entry = entriesNewestFirst[index];
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    // Date & Tags Column
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
                                  fontSize: 14,
                                  fontWeight: entry.isToday ? FontWeight.w800 : FontWeight.w600,
                                  color: entry.isToday ? AppTheme.goldLight : AppTheme.textPrimary,
                                ),
                              ),
                              if (entry.session != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    entry.session!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Badges (Today, Highest, Lowest)
                          Wrap(
                            spacing: 4,
                            children: [
                              if (entry.isToday)
                                _buildBadge('TODAY', AppTheme.goldPrimary, Colors.black),
                              if (entry.isYesterday)
                                _buildBadge('YESTERDAY', AppTheme.surfaceLight, AppTheme.textSecondary),
                              if (entry.isHighest)
                                _buildBadge('MONTH HIGH', AppTheme.redRate.withValues(alpha: 0.2), AppTheme.redRate),
                              if (entry.isLowest)
                                _buildBadge('MONTH LOW', AppTheme.greenRate.withValues(alpha: 0.2), AppTheme.greenRate),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price & Change Column
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(price, decimal: !isPavan),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: entry.isToday ? AppTheme.goldLight : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                isZero
                                    ? Icons.remove
                                    : isNegative
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                size: 12,
                                color: changeColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                isZero
                                    ? 'No change'
                                    : '${CurrencyFormatter.formatChange(change, isGram: !isPavan)} (${CurrencyFormatter.formatPercent(entry.changePercentage)})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: changeColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
