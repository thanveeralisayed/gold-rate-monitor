import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GoldHeader extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onOpenCalculator;

  const GoldHeader({
    super.key,
    required this.isLoading,
    required this.onRefresh,
    required this.onOpenCalculator,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App Title & Live Beacon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldPrimary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.monetization_on_rounded,
                color: Colors.black,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kerala Gold Rate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.greenRate,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Live 22K Market Tracker',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Actions: Calculator & Refresh
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.calculate_outlined, color: AppTheme.goldAccent),
              tooltip: 'Jewellery Price Calculator',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.surfaceElevated,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onOpenCalculator,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.goldPrimary,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary),
              tooltip: 'Refresh Rates',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.surfaceElevated,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isLoading ? null : onRefresh,
            ),
          ],
        ),
      ],
    );
  }
}
