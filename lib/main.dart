import 'package:flutter/material.dart';
import 'models/gold_rate_model.dart';
import 'services/gold_scraper_service.dart';
import 'theme/app_theme.dart';
import 'widgets/gold_header.dart';
import 'widgets/gold_hero_card.dart';
import 'widgets/gold_trend_chart.dart';
import 'widgets/daily_history_list.dart';
import 'widgets/gold_calculator_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    _loadGoldRates();
  }

  Future<void> _loadGoldRates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _scraperService.fetchGoldRates();
      if (mounted) {
        setState(() {
          _summary = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _summary = GoldScraperService.getFallbackData();
          _isLoading = false;
        });
      }
    }
  }

  void _openCalculator() {
    if (_summary == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoldCalculatorSheet(
        currentGramRate: _summary!.latestEntry.gramPrice,
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
                onRefresh: _loadGoldRates,
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
                        onRefresh: _loadGoldRates,
                        onOpenCalculator: _openCalculator,
                      ),
                      const SizedBox(height: 18),

                      if (summary != null) ...[
                        // Hero Card with today's rate & drop/gain
                        GoldHeroCard(
                          summary: summary,
                          isPavan: _isPavan,
                          onToggleUnit: () {
                            setState(() {
                              _isPavan = !_isPavan;
                            });
                          },
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
