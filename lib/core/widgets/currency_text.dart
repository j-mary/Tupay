import 'package:flutter/widgets.dart';

import '../utils/currency_formatter.dart';

class CurrencyText extends StatelessWidget {
  final double amount;
  final String currencyCode;
  final String? currencySymbol;
  final bool showSign;
  final TextStyle? style;
  final TextAlign? textAlign;

  const CurrencyText({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.currencySymbol,
    this.showSign = false,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyFormatter.format(
        amount: amount,
        code: currencyCode,
        symbol: currencySymbol,
        showSign: showSign,
      ),
      style: style,
      textAlign: textAlign,
    );
  }
}
