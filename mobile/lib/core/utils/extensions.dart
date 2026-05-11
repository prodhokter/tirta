extension StringExtension on String {
  String get capitalize => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  String get capitalizeWords =>
      split(' ').map((word) => word.capitalize).join(' ');
}

extension DoubleExtension on double {
  String get toPercentage => '${toStringAsFixed(1)}%';
}

extension IntExtension on int {
  String get toPercentage => '${((this / 15) * 100).toStringAsFixed(1)}%';
}
