import 'package:flutter/material.dart';
import 'models/gold_rate_model.dart';
import 'services/analytics_service.dart';
import 'services/background_service.dart';
import 'services/gold_scraper_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/gold_header.dart';
import 'widgets/gold_hero_card.dart';
import 'widgets/gold_trend_chart.dart';
import 'widgets/daily_history_list.dart';
import 'widgets/gold_calculator_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications and periodic background monitoring
  final notifications = NotificationService();
  await notifications.init();
  await notifications.requestPermission();
  await BackgroundService.initialize();

  // Initialize Firebase Analytics with safe fallback
  await AnalyticsService.initialize();

  runApp(const GoldRateApp());
}

class GoldRateApp extends StatelessWidget {
  const GoldRateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kerala Gold Rate Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorObservers: [
        if (AnalyticsService.observer != null) AnalyticsService.observer!,
      ],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoldScraperService _scraperService = GoldScraperService();
  GoldMonthSummary? _summary;
  bool _isLoading = true;
  bool _isPavan = true; // true: 1 Pavan (8g), false: 1 Gram

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(screenName: 'HomeScreen');
    _loadGoldRates(isManual: false);
  }

  Future<void> _loadGoldRates({bool isManual = false}) async {
    setState(() {
      _isLoading = true;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final data = await _scraperService.fetchGoldRates();
      stopwatch.stop();

      AnalyticsService.logRateRefresh(
        isManual: isManual,
        success: true,
        pavanPrice: data.latestEntry.pavanPrice,
        gramPrice: data.latestEntry.gramPrice,
        trend: data.trend,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      if (mounted) {
        setState(() {
          _summary = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      stopwatch.stop();
      final fallback = GoldScraperService.getFallbackData();

      AnalyticsService.logRateRefresh(
        isManual: isManual,
        success: false,
        pavanPrice: fallback.latestEntry.pavanPrice,
        gramPrice: fallback.latestEntry.gramPrice,
        trend: fallback.trend,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      if (mounted) {
        setState(() {
          _summary = fallback;
          _isLoading = false;
        });
      }
    }
  }

  void _openCalculator() {
    if (_summary == null) return;
    AnalyticsService.logCalculatorOpen(
      currentGramRate: _summary!.latestEntry.gramPrice,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoldCalculatorSheet(
        currentGramRate: _summary!.latestEntry.gramPrice,
      ),
    );
  }

  Future<void> _triggerTestNotification() async {
    AnalyticsService.logTestNotificationTriggered();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    await BackgroundService.checkNow(forceNotify: true);

    messenger.showSnackBar(
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
                'Notification sent! Periodic background checks are active.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;

    return Scaffold(
      body: SafeArea(
        child: summary == null && _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.goldPrimary),
                    SizedBox(height: 16),
                    Text(
                      'Fetching live Kerala gold rates...',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => _loadGoldRates(isManual: true),
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
                        isLoading: _isLoading,
                        onRefresh: () => _loadGoldRates(isManual: true),
                        onOpenCalculator: _openCalculator,
                        onTestNotification: _triggerTestNotification,
                      ),
                      const SizedBox(height: 18),

                      if (summary != null) ...[
                        // Hero Card with today's rate & drop/gain
                        GoldHeroCard(
                          summary: summary,
                          isPavan: _isPavan,
                          onUnitChanged: (isPavan) {
                            AnalyticsService.logRateUnitToggle(isPavan: isPavan);
                            setState(() {
                              _isPavan = isPavan;
                            });
                          },
                        ),
                        const SizedBox(height: 18),

                        // Notification Status Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E283D), Color(0xFF131B2B)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.goldPrimary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldPrimary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: AppTheme.goldAccent,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Rate Update Notifications Active',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Background worker checks for price drops & updates',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: _triggerTestNotification,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  backgroundColor: AppTheme.surfaceElevated,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Test',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.goldAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Advanced Interactive Trend Graph
                        GoldTrendChart(
                          entries: summary.entries,
                          isPavan: _isPavan,
                        ),
                        const SizedBox(height: 18),

                        // Quick info callout
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF1F293D)),
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
                        const SizedBox(height: 18),

                        // Day-by-Day Historical List
                        DailyHistoryList(
                          entriesNewestFirst: summary.entriesNewestFirst,
                          isPavan: _isPavan,
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
                                'Last updated: ${summary.lastUpdated.hour.toString().padLeft(2, '0')}:${summary.lastUpdated.minute.toString().padLeft(2, '0')} • Auto-synchronized',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCalculator,
        backgroundColor: AppTheme.goldPrimary,
        foregroundColor: Colors.black,
        elevation: 4,
        icon: const Icon(Icons.calculate_rounded),
        label: const Text(
          'Estimate Jewellery',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
