
class Value<T> {
  final String label;
  final T value;

  Value({
    required this.label,
    required this.value,
  });

  @override
  String toString() {
    return "$label ($value)";
  }
}
