import 'package:flutter/services.dart';

/// A [TextInputFormatter] that converts all input to lowercase.
///
/// Useful for fields like exam codes and usernames that should be
/// case-insensitive.
class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
