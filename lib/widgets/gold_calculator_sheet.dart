import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class GoldCalculatorSheet extends StatefulWidget {
  final double currentGramRate;

  const GoldCalculatorSheet({
    super.key,
    required this.currentGramRate,
  });

  @override
  State<GoldCalculatorSheet> createState() => _GoldCalculatorSheetState();
}

class _GoldCalculatorSheetState extends State<GoldCalculatorSheet> {
  late TextEditingController _weightController;
  double _weightInGrams = 8.0; // 1 Pavan default
  double _makingChargePercent = 8.0; // Typical 8%
  bool _includeGst = true; // 3% GST

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: '8');
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final basePrice = _weightInGrams * widget.currentGramRate;
    final makingChargeAmount = (basePrice * _makingChargePercent) / 100.0;
    final subtotal = basePrice + makingChargeAmount;
    final gstAmount = _includeGst ? (subtotal * 0.03) : 0.0;
    final grandTotal = subtotal + gstAmount;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calculate_rounded, color: AppTheme.goldAccent, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Jewellery Price Estimator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Text(
              'Calculate total cost based on today\'s Kerala 22K gold rate',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),

            // Weight Input
            const Text(
              'Gold Weight (Grams)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.goldLight),
              onChanged: _onWeightChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                suffixText: 'grams (${(_weightInGrams / 8).toStringAsFixed(2)} Pavan)',
                suffixStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.goldPrimary),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Preset Weight Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPresetChip('1 Gram', 1.0),
                  const SizedBox(width: 8),
                  _buildPresetChip('1 Pavan (8g)', 8.0),
                  const SizedBox(width: 8),
                  _buildPresetChip('2 Pavans (16g)', 16.0),
                  const SizedBox(width: 8),
                  _buildPresetChip('4 Pavans (32g)', 32.0),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Making Charges Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Making Charges (VA)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                Text(
                  '${_makingChargePercent.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.goldAccent),
                ),
              ],
            ),
            Slider(
              value: _makingChargePercent,
              min: 0.0,
              max: 20.0,
              divisions: 40,
              activeColor: AppTheme.goldPrimary,
              inactiveColor: AppTheme.surfaceLight,
              onChanged: (val) {
                setState(() {
                  _makingChargePercent = val;
                });
              },
            ),

            // GST Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Include 3% GST',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              subtitle: const Text(
                'Standard government jewellery tax',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              value: _includeGst,
              activeThumbColor: AppTheme.goldPrimary,
              onChanged: (val) {
                setState(() {
                  _includeGst = val;
                });
              },
            ),

            const SizedBox(height: 16),

            // Price Breakdown Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.goldCardGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.goldPrimary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _buildBreakdownRow(
                    'Base Gold (${_weightInGrams.toStringAsFixed(1)}g @ ${CurrencyFormatter.format(widget.currentGramRate, decimal: true)})',
                    CurrencyFormatter.format(basePrice),
                  ),
                  const SizedBox(height: 6),
                  _buildBreakdownRow(
                    'Making Charges (${_makingChargePercent.toStringAsFixed(1)}%)',
                    '+ ${CurrencyFormatter.format(makingChargeAmount)}',
                  ),
                  if (_includeGst) ...[
                    const SizedBox(height: 6),
                    _buildBreakdownRow(
                      'GST (3%)',
                      '+ ${CurrencyFormatter.format(gstAmount)}',
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Color(0xFF2B374E), height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated Total',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                        child: Text(
                          CurrencyFormatter.format(grandTotal),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
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
    );
  }

  Widget _buildPresetChip(String label, double grams) {
    final isSelected = (_weightInGrams - grams).abs() < 0.05;
    return GestureDetector(
      onTap: () => _setPresetWeight(grams),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.goldPrimary.withValues(alpha: 0.18) : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.goldPrimary : AppTheme.surfaceLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppTheme.goldLight : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}
