class GoldPriceEntry {
  final String date;
  final String? session;
  final bool isToday;
  final bool isYesterday;
  final int pavanPrice;
  final double gramPrice;
  final int changePavan;
  final double changeGram;
  final double changePercentage;
  final bool isHighest;
  final bool isLowest;

  GoldPriceEntry({
    required this.date,
    this.session,
    this.isToday = false,
    this.isYesterday = false,
    required this.pavanPrice,
    required this.gramPrice,
    required this.changePavan,
    required this.changeGram,
    required this.changePercentage,
    this.isHighest = false,
    this.isLowest = false,
  });

  String get displayTitle {
    if (session != null && session!.isNotEmpty) {
      return '$date ($session)';
    }
    return date;
  }
}

class GoldMonthSummary {
  final String monthName;
  final GoldPriceEntry latestEntry;
  final GoldPriceEntry? previousEntry;
  final int monthHigh;
  final String monthHighDate;
  final int monthLow;
  final String monthLowDate;
  final String trend; // 'Downward', 'Upward', 'Stable'
  final List<GoldPriceEntry> entries; // Chronological order (1st of month -> latest)
  final int overallMonthChangePavan;
  final double overallMonthChangePercent;
  final DateTime lastUpdated;

  GoldMonthSummary({
    required this.monthName,
    required this.latestEntry,
    this.previousEntry,
    required this.monthHigh,
    required this.monthHighDate,
    required this.monthLow,
    required this.monthLowDate,
    required this.trend,
    required this.entries,
    required this.overallMonthChangePavan,
    required this.overallMonthChangePercent,
    required this.lastUpdated,
  });

  List<GoldPriceEntry> get entriesNewestFirst => entries.reversed.toList();
}
