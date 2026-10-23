import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/gold_rate_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

enum ChartPeriod {
  fullMonth,
  last14Days,
  last7Days,
}

class GoldTrendChart extends StatefulWidget {
  final List<GoldPriceEntry> entries;
  final bool isPavan;

  const GoldTrendChart({
    super.key,
    required this.entries,
    required this.isPavan,
  });

  @override
  State<GoldTrendChart> createState() => _GoldTrendChartState();
}

class _GoldTrendChartState extends State<GoldTrendChart> {
  ChartPeriod _selectedPeriod = ChartPeriod.fullMonth;

  List<GoldPriceEntry> get _filteredEntries {
    if (widget.entries.isEmpty) return [];
    switch (_selectedPeriod) {
      case ChartPeriod.last7Days:
        return widget.entries.length > 7
            ? widget.entries.sublist(widget.entries.length - 7)
            : widget.entries;
      case ChartPeriod.last14Days:
        return widget.entries.length > 14
            ? widget.entries.sublist(widget.entries.length - 14)
            : widget.entries;
      case ChartPeriod.fullMonth:
        return widget.entries;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;

    if (filtered.isEmpty) {
      return const SizedBox.shrink();
    }

    final double minPrice = filtered
        .map((e) => widget.isPavan ? e.pavanPrice.toDouble() : e.gramPrice)
        .reduce(min);
    final double maxPrice = filtered
        .map((e) => widget.isPavan ? e.pavanPrice.toDouble() : e.gramPrice)
        .reduce(max);

    // Padding for chart aesthetics
    final double range = maxPrice - minPrice;
    final double yPadding = range == 0 ? 500 : range * 0.15;
    final double minY = (minPrice - yPadding).floorToDouble();
    final double maxY = (maxPrice + yPadding).ceilToDouble();

    final spots = <FlSpot>[];
    for (int i = 0; i < filtered.length; i++) {
      final yVal = widget.isPavan ? filtered[i].pavanPrice.toDouble() : filtered[i].gramPrice;
      spots.add(FlSpot(i.toDouble(), yVal));
    }

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
          // Header with Title and Range Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRICE MOVEMENT GRAPH',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.isPavan ? '1 Pavan (8g, 22K)' : '1 Gram (22K)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.goldLight,
                    ),
                  ),
                ],
              ),
              // Filter Chips
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    _buildPeriodButton('7D', ChartPeriod.last7Days),
                    _buildPeriodButton('14D', ChartPeriod.last14Days),
                    _buildPeriodButton('Month', ChartPeriod.fullMonth),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Chart Display
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (filtered.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: range > 0 ? range / 4 : 1000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFF1E293B),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: widget.isPavan ? 48 : 52,
                      interval: range > 0 ? range / 3 : 1000,
                      getTitlesWidget: (value, meta) {
                        if (value == minY || value == maxY) {
                          return const SizedBox.shrink();
                        }
                        String label;
                        if (widget.isPavan) {
                          label = '${(value / 1000).toStringAsFixed(1)}k';
                        } else {
                          label = '${(value / 1000).toStringAsFixed(2)}k';
                        }
                        return Text(
                          label,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: _calculateBottomInterval(filtered.length),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= filtered.length) {
                          return const SizedBox.shrink();
                        }
                        final dateStr = filtered[index].date;
                        final parts = dateStr.split('-');
                        final dayText = parts.isNotEmpty ? parts[0] : dateStr;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dayText,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= filtered.length) return null;
                        final entry = filtered[index];
                        final price = widget.isPavan ? entry.pavanPrice : entry.gramPrice;
                        final change = widget.isPavan ? entry.changePavan : entry.changeGram;
                        final changeText = CurrencyFormatter.formatChange(change, isGram: !widget.isPavan);

                        return LineTooltipItem(
                          '${entry.displayTitle}\n',
                          const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '${CurrencyFormatter.format(price, decimal: !widget.isPavan)}\n',
                              style: const TextStyle(
                                color: AppTheme.goldLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: change == 0 ? 'No change' : '$changeText vs prev',
                              style: TextStyle(
                                color: change < 0
                                    ? AppTheme.redRate
                                    : change > 0
                                        ? AppTheme.greenRate
                                        : AppTheme.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF099), Color(0xFFF5BA42), Color(0xFFEAB308)],
                    ),
                    barWidth: 3.2,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: AppTheme.chartAreaGradient,
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final entry = filtered[index];
                        if (entry.isLowest) {
                          return FlDotCirclePainter(
                            radius: 5.5,
                            color: AppTheme.greenRate,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        }
                        if (entry.isHighest) {
                          return FlDotCirclePainter(
                            radius: 5.5,
                            color: AppTheme.redRate,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        }
                        if (index == filtered.length - 1) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: AppTheme.goldAccent,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 1.5,
                          color: AppTheme.goldPrimary.withValues(alpha: 0.5),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(AppTheme.goldAccent, 'Latest Rate'),
              const SizedBox(width: 14),
              _buildLegendDot(AppTheme.greenRate, 'Lowest (Best Buy)'),
              const SizedBox(width: 14),
              _buildLegendDot(AppTheme.redRate, 'Month Peak'),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateBottomInterval(int length) {
    if (length <= 7) return 1;
    if (length <= 15) return 2;
    return 4;
  }

  Widget _buildPeriodButton(String text, ChartPeriod period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.goldPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
