import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GoldHeader extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onOpenCalculator;
  final VoidCallback onTestNotification;

  const GoldHeader({
    super.key,
    required this.isLoading,
    required this.onRefresh,
    required this.onOpenCalculator,
    required this.onTestNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App Title & Live Beacon
        Expanded(
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldPrimary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: AppTheme.goldGradient,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.currency_rupee_rounded,
                            color: AppTheme.goldLight,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
                      overflow: TextOverflow.ellipsis,
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
                        const Flexible(
                          child: Text(
                            'Live 22K Market Tracker',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Actions: Bell Alert, Calculator, Refresh
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_active_outlined, color: AppTheme.goldAccent, size: 20),
              tooltip: 'Test Rate Alert Notification',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.surfaceElevated,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onTestNotification,
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.calculate_outlined, color: AppTheme.textPrimary, size: 20),
              tooltip: 'Jewellery Price Calculator',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.surfaceElevated,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onOpenCalculator,
            ),
            const SizedBox(width: 6),
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
                  : const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary, size: 20),
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
