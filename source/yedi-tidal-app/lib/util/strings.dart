extension StringCasingExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

extension StringTitleCase on String {
  String toTitleCase() {
    return split(' ').map((word) => word.capitalizeFirst()).join(' ');
  }
}

extension StringTrimSpaces on String {
  String removeAllWhiteSpace() {
    return replaceAll(RegExp(r'\s+'), '');
  }
}

extension SnakeCase on String {
  String toSnakeCase() {
    return replaceAllMapped(
            RegExp(r'[A-Z]'), (match) => '_${match[0]!.toLowerCase()}')
        .replaceAll(RegExp(r'[\s]+'), '_')
        .replaceAll(RegExp(r'_{2,}'), '_')
        .replaceAll(
            RegExp(r'^_|_$'), ''); // Remove leading and trailing underscores
  }
}

extension NumericCheck on String {
  bool isNumeric() {
    return double.tryParse(this) != null;
  }
}
