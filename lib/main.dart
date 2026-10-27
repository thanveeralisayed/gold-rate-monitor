import 'package:flutter/material.dart';
import 'models/gold_rate_model.dart';
import 'services/analytics_service.dart';
import 'services/background_service.dart';
import 'services/gold_scraper_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/rates_view.dart';
import 'widgets/history_view.dart';
import 'widgets/calculator_view.dart';
import 'widgets/alerts_view.dart';

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
      title: 'Gold Rate Monitor',
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
  int _currentTabIndex = 0; // 0: Rates, 1: Ledger, 2: Calculator, 3: Alerts

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(screenName: 'HomeScreen');
    _initRates();
  }

  Future<void> _initRates() async {
    // 1. Immediately render cached rates if available for zero-wait launch
    final cached = await _scraperService.getCachedRates();
    if (cached != null && mounted) {
      setState(() {
        _summary = cached;
        _isLoading = false;
      });
    }

    // 2. Check if a window scrape (after 10am or after 5pm) is needed
    final needsAutoScrape = await _scraperService.shouldAutoScrape();
    if (needsAutoScrape || _summary == null) {
      await _loadGoldRates(isManual: false);
    }
  }

  Future<void> _loadGoldRates({bool isManual = false}) async {
    if (_summary == null) {
      setState(() {
        _isLoading = true;
      });
    }

    final stopwatch = Stopwatch()..start();
    try {
      final data = await _scraperService.fetchGoldRates(isManual: isManual);
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

        if (isManual) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.surfaceElevated,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppTheme.greenRate, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Live rates updated from KeralaGold.com',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      stopwatch.stop();
      final cached = await _scraperService.getCachedRates();
      final fallback = cached ?? GoldScraperService.getFallbackData();

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

  void _onTabSelected(int index) {
    if (_currentTabIndex == index) return;
    setState(() {
      _currentTabIndex = index;
    });

    const tabNames = ['RatesView', 'HistoryView', 'CalculatorView', 'AlertsView'];
    if (index >= 0 && index < tabNames.length) {
      AnalyticsService.logScreenView(screenName: tabNames[index]);
    }
  }

  void _openCalculator() {
    _onTabSelected(2);
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
      backgroundColor: AppTheme.background,
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
            : IndexedStack(
                index: _currentTabIndex,
                children: [
                  // Tab 0: Rates
                  RatesView(
                    summary: summary ?? GoldScraperService.getFallbackData(),
                    isPavan: _isPavan,
                    isLoading: _isLoading,
                    onUnitChanged: (isPavan) {
                      AnalyticsService.logRateUnitToggle(isPavan: isPavan);
                      setState(() {
                        _isPavan = isPavan;
                      });
                    },
                    onRefresh: () => _loadGoldRates(isManual: true),
                    onOpenCalculator: _openCalculator,
                    onTestNotification: _triggerTestNotification,
                  ),

                  // Tab 1: History / Ledger
                  HistoryView(
                    summary: summary ?? GoldScraperService.getFallbackData(),
                    isPavan: _isPavan,
                    onUnitChanged: (isPavan) {
                      AnalyticsService.logRateUnitToggle(isPavan: isPavan);
                      setState(() {
                        _isPavan = isPavan;
                      });
                    },
                    onRefresh: () => _loadGoldRates(isManual: true),
                  ),

                  // Tab 2: Jewellery Cost Calculator
                  CalculatorView(
                    currentGramRate: (summary ?? GoldScraperService.getFallbackData()).latestEntry.gramPrice,
                  ),

                  // Tab 3: Alerts & Background Sync Schedule
                  AlertsView(
                    onTriggerTestNotification: _triggerTestNotification,
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(color: AppTheme.surfaceBorder, width: 1),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: _onTabSelected,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.goldLight,
            unselectedItemColor: AppTheme.textMuted,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up_rounded),
                activeIcon: Icon(Icons.trending_up_rounded, color: AppTheme.goldLight),
                label: 'Rates',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                activeIcon: Icon(Icons.history_rounded, color: AppTheme.goldLight),
                label: 'Ledger',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate_rounded),
                activeIcon: Icon(Icons.calculate_rounded, color: AppTheme.goldLight),
                label: 'Calculator',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active_rounded),
                activeIcon: Icon(Icons.notifications_active_rounded, color: AppTheme.goldLight),
                label: 'Alerts',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
