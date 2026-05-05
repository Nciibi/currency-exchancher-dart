import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================
// Entry point of the application
// ============================================================
void main() {
  runApp(const CurrencyConverterApp());
}

/// Root widget of the app — sets up MaterialApp with theme.
class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      // App-wide theme using Material Design 3
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0), // Deep blue
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const ConverterScreen(),
    );
  }
}

// ============================================================
// Main converter screen — this is a StatefulWidget because
// the UI changes as the user types or selects currencies.
// ============================================================
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  // ----------------------------------------------------------
  // Hardcoded exchange rates relative to USD (1 USD = X units)
  // These are fixed values — no API calls needed.
  // "DT" represents the Tunisian Dinar (TND).
  // ----------------------------------------------------------
  final Map<String, double> _ratesToUsd = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 154.50,
    'CAD': 1.36,
    'DT': 3.12, // Tunisian Dinar
  };

  // Friendly display names for each currency code
  final Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CAD': 'Canadian Dollar',
    'DT': 'Tunisian Dinar',
  };

  // Currency flag emojis for visual flair
  final Map<String, String> _currencyFlags = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'JPY': '🇯🇵',
    'CAD': '🇨🇦',
    'DT': '🇹🇳',
  };

  // ----------------------------------------------------------
  // State variables
  // ----------------------------------------------------------
  String _fromCurrency = 'USD'; // Source currency
  String _toCurrency = 'DT'; // Target currency
  String _inputAmount = ''; // Raw text from the input field
  double _convertedAmount = 0.0; // Result of the conversion
  final TextEditingController _controller = TextEditingController();

  // ----------------------------------------------------------
  // Conversion logic
  // ----------------------------------------------------------

  /// Converts [amount] from [from] currency to [to] currency.
  /// Strategy: convert source → USD → target.
  double _convert(double amount, String from, String to) {
    if (from == to) return amount;

    // Step 1: Convert the source amount to USD
    final double amountInUsd = amount / _ratesToUsd[from]!;

    // Step 2: Convert USD to the target currency
    final double result = amountInUsd * _ratesToUsd[to]!;

    return result;
  }

  /// Called every time the input text changes.
  /// Validates the input and triggers a new conversion.
  void _onAmountChanged(String value) {
    setState(() {
      _inputAmount = value;

      // If the field is empty, reset the result
      if (value.isEmpty) {
        _convertedAmount = 0.0;
        return;
      }

      // Try to parse the input; if invalid, set result to 0
      final double? parsed = double.tryParse(value);
      if (parsed == null || parsed < 0) {
        _convertedAmount = 0.0;
      } else {
        _convertedAmount = _convert(parsed, _fromCurrency, _toCurrency);
      }
    });
  }

  /// Swaps the source and target currencies.
  void _swapCurrencies() {
    setState(() {
      // Swap the two currency codes
      final String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;

      // Re-run conversion with the swapped currencies
      if (_inputAmount.isNotEmpty) {
        final double? parsed = double.tryParse(_inputAmount);
        if (parsed != null && parsed >= 0) {
          _convertedAmount = _convert(parsed, _fromCurrency, _toCurrency);
        }
      }
    });
  }

  /// Returns the exchange rate string for display (e.g. "1 USD = 3.12 DT")
  String _getExchangeRateText() {
    final double rate = _convert(1.0, _fromCurrency, _toCurrency);
    return '1 $_fromCurrency = ${rate.toStringAsFixed(4)} $_toCurrency';
  }

  /// Formats the converted amount for display.
  /// Uses 2 decimal places for most currencies, 0 for JPY.
  String _formatResult(double value) {
    if (_toCurrency == 'JPY') {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  // Clean up the controller when the widget is removed
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      // ---- App Bar ----
      appBar: AppBar(
        title: const Text(
          '💱 Currency Converter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        elevation: 0,
      ),

      backgroundColor: colors.surface,

      // ---- Body ----
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Exchange rate info banner ----
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colors.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getExchangeRateText(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---- Amount input field ----
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              // Allow only numbers and one decimal point
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: _onAmountChanged,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: colors.surfaceContainerLowest,
              ),
            ),

            const SizedBox(height: 24),

            // ---- Currency selectors + swap button ----
            Row(
              children: [
                // FROM currency dropdown
                Expanded(
                  child: _buildCurrencyDropdown(
                    label: 'From',
                    value: _fromCurrency,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _fromCurrency = newValue;
                        });
                        _onAmountChanged(_inputAmount);
                      }
                    },
                  ),
                ),

                // Swap button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton.filled(
                    onPressed: _swapCurrencies,
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Swap currencies',
                    style: IconButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                  ),
                ),

                // TO currency dropdown
                Expanded(
                  child: _buildCurrencyDropdown(
                    label: 'To',
                    value: _toCurrency,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _toCurrency = newValue;
                        });
                        _onAmountChanged(_inputAmount);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ---- Conversion result card ----
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  Text(
                    'Converted Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Show the result with the target currency flag
                  Text(
                    '${_currencyFlags[_toCurrency]} ${_formatResult(_convertedAmount)} $_toCurrency',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Show the original input for reference
                  if (_inputAmount.isNotEmpty)
                    Text(
                      '${_currencyFlags[_fromCurrency]} $_inputAmount $_fromCurrency',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onPrimaryContainer.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---- Quick-pick amount buttons ----
            Text(
              'Quick Amounts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 10, 50, 100, 500, 1000].map((amount) {
                return ActionChip(
                  label: Text('$amount'),
                  onPressed: () {
                    _controller.text = amount.toString();
                    _onAmountChanged(amount.toString());
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // ---- Footer note ----
            Text(
              'ℹ️ Exchange rates are hardcoded for demonstration purposes\nand do not reflect real-time market values.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Helper: builds a styled dropdown for selecting a currency
  // ----------------------------------------------------------
  Widget _buildCurrencyDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the dropdown
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        // Dropdown wrapped in a styled container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(12.0),
            color: colors.surfaceContainerLowest,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: onChanged,
              // Build a dropdown item for each currency
              items: _ratesToUsd.keys.map((String code) {
                return DropdownMenuItem<String>(
                  value: code,
                  child: Row(
                    children: [
                      Text(
                        _currencyFlags[code]!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        code,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
