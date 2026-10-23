import 'package:flutter/material.dart';
import '../models/gold_rate_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class GoldHeroCard extends StatelessWidget {
  final GoldMonthSummary summary;
  final bool isPavan;
  final VoidCallback onToggleUnit;

  const GoldHeroCard({
    super.key,
    required this.summary,
    required this.isPavan,
    required this.onToggleUnit,
  });

  @override
  Widget build(BuildContext context) {
    final latest = summary.latestEntry;
    final currentPrice = isPavan ? latest.pavanPrice : latest.gramPrice;
    final changeAmount = isPavan ? latest.changePavan : latest.changeGram;
    final isNegative = changeAmount < 0;
    final isZero = changeAmount == 0;

    final badgeColor = isZero
        ? AppTheme.textMuted
        : isNegative
            ? AppTheme.redRate
            : AppTheme.greenRate;
    final badgeBg = isZero
        ? AppTheme.surfaceLight.withValues(alpha: 0.3)
        : isNegative
            ? AppTheme.redBackground
            : AppTheme.greenBackground;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.goldCardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.goldPrimary.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldPrimary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag + Unit Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.goldPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.goldPrimary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 14, color: AppTheme.goldAccent),
                    const SizedBox(width: 5),
                    Text(
                      'KERALA • 22K (916 GOLD)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.goldLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Unit Toggle Switch
              GestureDetector(
                onTap: onToggleUnit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.surfaceLight),
                  ),
                  child: Row(
                    children: [
                      _buildUnitChip('1 Pavan', isPavan),
                      const SizedBox(width: 4),
                      _buildUnitChip('1 Gram', !isPavan),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Rate title
          Text(
            "TODAY'S RATE (${latest.date})",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),

          // Hero Price Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                child: Text(
                  CurrencyFormatter.format(currentPrice, decimal: !isPavan),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isPavan ? '/ 8 grams (1 Pavan)' : '/ 1 gram',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Daily Change & Trend Pills
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              // Day Change Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isZero
                          ? Icons.remove
                          : isNegative
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                      size: 15,
                      color: badgeColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isZero
                          ? 'Unchanged today'
                          : '${CurrencyFormatter.formatChange(changeAmount, isGram: !isPavan)} (${CurrencyFormatter.formatPercent(latest.changePercentage)})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Trend Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      summary.trend.toLowerCase() == 'downward'
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      size: 16,
                      color: summary.trend.toLowerCase() == 'downward'
                          ? AppTheme.greenRate // Drop in gold rate is favorable for buyers
                          : AppTheme.goldAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Trend: ${summary.trend}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFF1F293D), height: 1),
          const SizedBox(height: 16),

          // Monthly Statistics Strip (High, Low, Net Change)
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: 'Month High',
                  value: CurrencyFormatter.format(
                    isPavan ? summary.monthHigh : (summary.monthHigh / 8.0),
                    decimal: !isPavan,
                  ),
                  subtext: summary.monthHighDate,
                  color: AppTheme.goldLight,
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFF1F293D)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _buildStatItem(
                    title: 'Month Low',
                    value: CurrencyFormatter.format(
                      isPavan ? summary.monthLow : (summary.monthLow / 8.0),
                      decimal: !isPavan,
                    ),
                    subtext: summary.monthLowDate,
                    color: AppTheme.greenRate,
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFF1F293D)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _buildStatItem(
                    title: 'Month Change',
                    value: CurrencyFormatter.formatChange(
                      isPavan ? summary.overallMonthChangePavan : (summary.overallMonthChangePavan / 8.0),
                      isGram: !isPavan,
                    ),
                    subtext: CurrencyFormatter.formatPercent(summary.overallMonthChangePercent),
                    color: summary.overallMonthChangePavan < 0 ? AppTheme.redRate : AppTheme.greenRate,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.goldPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.black : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required String subtext,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          subtext,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
