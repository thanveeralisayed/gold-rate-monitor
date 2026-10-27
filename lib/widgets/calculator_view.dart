import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class CalculatorView extends StatefulWidget {
  final double currentGramRate;

  const CalculatorView({
    super.key,
    required this.currentGramRate,
  });

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  late TextEditingController _weightController;
  double _weightInGrams = 8.0; // 1 Pavan default
  double _makingChargePercent = 8.5; // Stitch standard default
  bool _includeGst = true; // 3% GST

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: '8');
    AnalyticsService.logScreenView(screenName: 'CalculatorView');
  }

  @override
  void dispose() {
    _logCalculation();
    _weightController.dispose();
    super.dispose();
  }

  void _logCalculation() {
    final basePrice = _weightInGrams * widget.currentGramRate;
    final makingChargeAmount = (basePrice * _makingChargePercent) / 100.0;
    final subtotal = basePrice + makingChargeAmount;
    final gstAmount = _includeGst ? (subtotal * 0.03) : 0.0;
    final grandTotal = subtotal + gstAmount;

    AnalyticsService.logCalculatorCalculation(
      weightInGrams: _weightInGrams,
      makingChargePercent: _makingChargePercent,
      includeGst: _includeGst,
      grandTotal: grandTotal,
    );
  }

  void _onWeightChanged(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null && parsed >= 0) {
      setState(() {
        _weightInGrams = parsed;
      });
    }
  }

  void _setPresetWeight(double grams) {
    setState(() {
      _weightInGrams = grams;
      _weightController.text = grams % 1 == 0 ? grams.toInt().toString() : grams.toString();
    });
  }

  void _adjustWeight(double delta) {
    final newWeight = (_weightInGrams + delta).clamp(0.1, 1000.0);
    setState(() {
      _weightInGrams = double.parse(newWeight.toStringAsFixed(2));
      _weightController.text = _weightInGrams % 1 == 0
          ? _weightInGrams.toInt().toString()
          : _weightInGrams.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = _weightInGrams * widget.currentGramRate;
    final makingChargeAmount = (basePrice * _makingChargePercent) / 100.0;
    final subtotal = basePrice + makingChargeAmount;
    final gstAmount = _includeGst ? (subtotal * 0.03) : 0.0;
    final grandTotal = subtotal + gstAmount;

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
                            'JEWELLERY ESTIMATOR',
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
                          '22K (916 Hallmarked)',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Purchase Calculator',
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
                  Icons.calculate_rounded,
                  color: AppTheme.goldAccent,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Live Benchmark Rate Bar
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LIVE BENCHMARK',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyFormatter.format(widget.currentGramRate, decimal: true)} / gram',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 26,
                  width: 1,
                  color: AppTheme.surfaceLight.withValues(alpha: 0.4),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '1 PAVAN (8g)',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(widget.currentGramRate * 8),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.goldLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Weight Input Section
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ORNAMENT WEIGHT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${(_weightInGrams / 8.0).toStringAsFixed(2)} Pavans',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Weight Input Field with Stepper Controls
                Row(
                  children: [
                    // Decrement Button
                    IconButton(
                      onPressed: () => _adjustWeight(-1.0),
                      icon: const Icon(Icons.remove_circle_outline, color: AppTheme.goldAccent),
                      iconSize: 28,
                    ),
                    const SizedBox(width: 4),

                    // Text Field
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: TextField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixText: 'g',
                            suffixStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          onChanged: _onWeightChanged,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Increment Button
                    IconButton(
                      onPressed: () => _adjustWeight(1.0),
                      icon: const Icon(Icons.add_circle_outline, color: AppTheme.goldAccent),
                      iconSize: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Preset Weight Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildWeightPresetChip('1g', 1.0),
                    _buildWeightPresetChip('4g (½ Pavan)', 4.0),
                    _buildWeightPresetChip('8g (1 Pavan)', 8.0),
                    _buildWeightPresetChip('16g (2 Pavans)', 16.0),
                    _buildWeightPresetChip('24g (3 Pavans)', 24.0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Making Charges (VA / Value Addition)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MAKING CHARGES (VA)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${_makingChargePercent.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.goldLight,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.goldPrimary,
                    inactiveTrackColor: AppTheme.surfaceLight.withValues(alpha: 0.4),
                    thumbColor: AppTheme.goldLight,
                    overlayColor: AppTheme.goldPrimary.withValues(alpha: 0.15),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _makingChargePercent,
                    min: 0.0,
                    max: 30.0,
                    divisions: 60,
                    onChanged: (val) {
                      setState(() {
                        _makingChargePercent = double.parse(val.toStringAsFixed(1));
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // 4 Stitch VA Style Preset Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildVaChip('5% Simple', 5.0),
                    _buildVaChip('8.5% Standard', 8.5),
                    _buildVaChip('12% Antique', 12.0),
                    _buildVaChip('16% Bridal', 16.0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3% GST Switch
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
                        'Include 3% GST',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Precious metals tax as mandated by Indian Law',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _includeGst,
                  activeColor: AppTheme.goldPrimary,
                  activeTrackColor: AppTheme.goldPrimary.withValues(alpha: 0.3),
                  inactiveThumbColor: AppTheme.textMuted,
                  inactiveTrackColor: AppTheme.surfaceElevated,
                  onChanged: (val) {
                    setState(() {
                      _includeGst = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Itemized Bill Receipt Card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2638), Color(0xFF141A29)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppTheme.goldPrimary.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldPrimary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ESTIMATED BILL BREAKDOWN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppTheme.goldLight,
                      ),
                    ),
                    Icon(Icons.receipt_long_rounded, color: AppTheme.goldAccent, size: 18),
                  ],
                ),
                const SizedBox(height: 16),

                _buildReceiptRow(
                  'Gold Value (${_weightInGrams}g × ${CurrencyFormatter.format(widget.currentGramRate, decimal: true)})',
                  CurrencyFormatter.format(basePrice),
                ),
                const SizedBox(height: 8),

                _buildReceiptRow(
                  'Making Charges (VA ${_makingChargePercent}%)',
                  CurrencyFormatter.format(makingChargeAmount),
                ),
                const SizedBox(height: 8),

                _buildReceiptRow(
                  'Pre-Tax Subtotal',
                  CurrencyFormatter.format(subtotal),
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 8),

                _buildReceiptRow(
                  'GST (${_includeGst ? '3%' : '0%'})',
                  CurrencyFormatter.format(gstAmount),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFF283548), height: 1),
                ),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      'GRAND TOTAL',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.format(grandTotal),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.goldLight,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Footnote
          const Center(
            child: Text(
              'Excludes stone charges, hallmark fee (₹45+GST) & retail discounts.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWeightPresetChip(String label, double grams) {
    final isSelected = (_weightInGrams - grams).abs() < 0.01;
    return GestureDetector(
      onTap: () => _setPresetWeight(grams),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.goldPrimary : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.goldPrimary : AppTheme.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.black : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildVaChip(String label, double percent) {
    final isSelected = (_makingChargePercent - percent).abs() < 0.05;
    return GestureDetector(
      onTap: () {
        setState(() {
          _makingChargePercent = percent;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.goldPrimary.withValues(alpha: 0.2) : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.goldPrimary : AppTheme.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppTheme.goldLight : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
