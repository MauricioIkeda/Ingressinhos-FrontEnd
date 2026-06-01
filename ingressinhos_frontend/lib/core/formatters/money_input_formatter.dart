import 'package:flutter/services.dart';

class MoneyInputFormatter extends TextInputFormatter {
  const MoneyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9,.]'), '');

    if (raw.isEmpty) {
      return const TextEditingValue();
    }

    final lastComma = raw.lastIndexOf(',');
    final lastDot = raw.lastIndexOf('.');
    final separatorIndex = lastComma > lastDot ? lastComma : lastDot;

    String formatted;
    if (separatorIndex == -1) {
      formatted = raw.replaceAll(RegExp(r'[^0-9]'), '');
    } else {
      final separator = raw[separatorIndex];
      final integerPart = raw
          .substring(0, separatorIndex)
          .replaceAll(RegExp(r'[^0-9]'), '');
      final decimalPart = raw
          .substring(separatorIndex + 1)
          .replaceAll(RegExp(r'[^0-9]'), '');

      final decimals = decimalPart.length > 2
          ? decimalPart.substring(0, 2)
          : decimalPart;
      formatted =
          '${integerPart.isEmpty ? '0' : integerPart}$separator$decimals';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

double? parseMoney(String value) {
  final raw = value.trim();
  if (raw.isEmpty) return null;

  final sanitized = raw.replaceAll(RegExp(r'[^0-9,.]'), '');
  if (sanitized.isEmpty) return null;

  final lastComma = sanitized.lastIndexOf(',');
  final lastDot = sanitized.lastIndexOf('.');
  final decimalIndex = lastComma > lastDot ? lastComma : lastDot;

  if (decimalIndex == -1) {
    return double.tryParse(sanitized.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  final integerPart = sanitized
      .substring(0, decimalIndex)
      .replaceAll(RegExp(r'[^0-9]'), '');
  final decimalPart = sanitized
      .substring(decimalIndex + 1)
      .replaceAll(RegExp(r'[^0-9]'), '');

  final normalized =
      '${integerPart.isEmpty ? '0' : integerPart}.${decimalPart.isEmpty ? '0' : decimalPart}';

  return double.tryParse(normalized);
}

String? validateMoneyField(
  String? value, {
  required bool isRequired,
  String emptyMessage = 'Informe um valor',
}) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return isRequired ? emptyMessage : null;
  }

  final parsed = parseMoney(raw);
  if (parsed == null) {
    return 'Informe um valor valido';
  }

  if (parsed <= 0) {
    return 'O valor precisa ser maior que zero';
  }

  return null;
}
