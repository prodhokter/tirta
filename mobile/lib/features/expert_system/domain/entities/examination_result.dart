class ExaminationResult {
  final int score;
  final double percentage;
  final String riskLevel;
  final bool isValid;
  final String conclusion;
  final List<String> detectedSymptoms;
  final List<bool> answers;

  const ExaminationResult({
    required this.score,
    required this.percentage,
    required this.riskLevel,
    required this.isValid,
    required this.conclusion,
    required this.detectedSymptoms,
    required this.answers,
  });
}
