import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/analytics_service.dart';
import '../services/background_service.dart';
import '../theme/app_theme.dart';

class AlertsView extends StatefulWidget {
  final Future<void> Function()? onTriggerTestNotification;

  const AlertsView({
    super.key,
    this.onTriggerTestNotification,
  });

  @override
  State<AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends State<AlertsView> {
  bool _alertsEnabled = true;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(screenName: 'AlertsView');
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _alertsEnabled = prefs.getBool('price_alerts_enabled') ?? true;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleAlerts(bool value) async {
    setState(() {
      _alertsEnabled = value;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('price_alerts_enabled', value);
    } catch (_) {}
  }

  Future<void> _sendTestAlert() async {
    if (_isTesting) return;
    setState(() {
      _isTesting = true;
    });

    try {
      if (widget.onTriggerTestNotification != null) {
        await widget.onTriggerTestNotification!();
      } else {
        AnalyticsService.logTestNotificationTriggered();
        await BackgroundService.checkNow(forceNotify: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.surfaceElevated,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: const Row(
                children: [
                  Icon(Icons.notifications_active, color: AppTheme.goldAccent, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sample Kerala gold alert sent to system tray!',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
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
                            'NOTIFICATION CENTER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: AppTheme.goldLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Intelligent Sync',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Price Alerts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppTheme.goldAccent,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Background Engine Status Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E283D), Color(0xFF131B2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.goldPrimary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.greenRate,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.greenRate,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'Background Engine Active',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.greenBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'OPTIMIZED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.greenRate,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Monitors Kerala bullion market changes with zero battery drain. Automatically syncs after the official 10:00 AM & 05:00 PM market fixes.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Master Push Toggle Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bullion Rate Alerts',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Receive heads-up whenever 22K rates rise or drop',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _alertsEnabled,
                  activeColor: AppTheme.goldPrimary,
                  activeTrackColor: AppTheme.goldPrimary.withValues(alpha: 0.3),
                  inactiveThumbColor: AppTheme.textMuted,
                  inactiveTrackColor: AppTheme.surfaceElevated,
                  onChanged: _toggleAlerts,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Test Alert Button Trigger
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SAMPLE NOTIFICATION TEST',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Dispatch an immediate sample alert to verify notification permissions and tray display.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _sendTestAlert,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceElevated,
                      foregroundColor: AppTheme.goldLight,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppTheme.goldPrimary.withValues(alpha: 0.3)),
                      ),
                    ),
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.goldAccent),
                          )
                        : const Icon(Icons.send_rounded, size: 16),
                    label: Text(
                      _isTesting ? 'Sending Notification...' : 'Send Sample Alert',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Market Schedule Section
          const Text(
            'OFFICIAL BULLION SCHEDULE (KERALA)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Morning Fix Card
          _buildScheduleCard(
            time: '10:00 AM',
            title: 'Morning Market Open',
            description: 'Kerala Bullion Merchants Association announces opening benchmark 22K rate based on global gold prices and INR forex parity.',
            badge: 'Primary Window',
            badgeColor: AppTheme.goldAccent,
            icon: Icons.wb_sunny_rounded,
          ),
          const SizedBox(height: 10),

          // Evening Fix Card
          _buildScheduleCard(
            time: '05:00 PM',
            title: 'Evening Session Fix',
            description: 'Closing bullion rate adjustments based on intra-day MCX Mumbai futures settlements and US session bullion movement.',
            badge: 'Secondary Window',
            badgeColor: AppTheme.greenSecondary,
            icon: Icons.nightlight_round,
          ),
          const SizedBox(height: 20),

          // Anti-Rate Limit Policy Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 20, color: AppTheme.goldAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'To protect KeralaGold.com from rate limits, automated background checks run strictly after 10 AM & 5 PM. On-demand manual refresh is always available in the Rates tab.',
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required String time,
    required String title,
    required String description,
    required String badge,
    required Color badgeColor,
    required IconData icon,
  }) {
    return Container(
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: badgeColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
