class ExaminationResult {
  final int score;
  final double percentage;
  final String riskLevel;
  final String validityStatus;
  final String recommendation;
  final List<String> detectedSymptoms;
  final List<String> flags;
  final bool isUrgent;
  final Map<String, bool> answers;

  const ExaminationResult({
    required this.score,
    required this.percentage,
    required this.riskLevel,
    required this.validityStatus,
    required this.recommendation,
    required this.detectedSymptoms,
    required this.flags,
    required this.isUrgent,
    required this.answers,
  });

  /// Backward-compatible getter: valid if validityStatus == "VALID"
  bool get isValid => validityStatus == 'VALID';
}
