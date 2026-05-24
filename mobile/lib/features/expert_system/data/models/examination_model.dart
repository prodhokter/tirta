import 'package:tirta/features/expert_system/domain/entities/examination_result.dart';

class ExaminationModel {
  final String? id;
  final String userId;
  final int score;
  final double percentage;
  final String riskLevel;
  final bool isValid;
  final String conclusion;
  final List<String> detectedSymptoms;
  final Map<String, bool> answers;
  final List<String> flags;
  final bool isUrgent;
  final DateTime createdAt;

  const ExaminationModel({
    this.id,
    required this.userId,
    required this.score,
    required this.percentage,
    required this.riskLevel,
    required this.isValid,
    required this.conclusion,
    required this.detectedSymptoms,
    required this.answers,
    required this.flags,
    required this.isUrgent,
    required this.createdAt,
  });

  factory ExaminationModel.fromResult({
    required ExaminationResult result,
    required String userId,
  }) {
    return ExaminationModel(
      userId: userId,
      score: result.score,
      percentage: result.percentage,
      riskLevel: result.riskLevel,
      isValid: result.isValid,
      conclusion: result.recommendation,
      detectedSymptoms: result.detectedSymptoms,
      answers: result.answers,
      flags: result.flags,
      isUrgent: result.isUrgent,
      createdAt: DateTime.now(),
    );
  }

  factory ExaminationModel.fromJson(Map<String, dynamic> json) {
    // Parse answers — support both Map<String, bool> and legacy List<bool>
    Map<String, bool> parsedAnswers = {};
    final rawAnswers = json['answers'];
    if (rawAnswers is Map) {
      parsedAnswers = Map<String, bool>.from(
        rawAnswers.map((k, v) => MapEntry(k.toString(), v as bool)),
      );
    } else if (rawAnswers is List) {
      // Legacy format: List<bool> → convert to Map using G01-G15 codes
      for (int i = 0; i < rawAnswers.length && i < 15; i++) {
        final code = 'G${(i + 1).toString().padLeft(2, '0')}';
        parsedAnswers[code] = rawAnswers[i] is bool
            ? rawAnswers[i] as bool
            : (rawAnswers[i] as Map?)?['answer'] as bool? ?? false;
      }
    }

    // Parse flags
    List<String> parsedFlags = [];
    if (json['flags'] != null && json['flags'] is List) {
      parsedFlags = List<String>.from(json['flags'] as List);
    }

    return ExaminationModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      score: json['score'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      isValid: json['is_valid'] as bool,
      conclusion: json['conclusion'] as String? ?? '',
      detectedSymptoms: json['detected_symptoms'] != null
          ? List<String>.from(json['detected_symptoms'] as List)
          : [],
      answers: parsedAnswers,
      flags: parsedFlags,
      isUrgent: json['is_urgent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'score': score,
      'percentage': percentage,
      'risk_level': riskLevel,
      'is_valid': isValid,
      'conclusion': conclusion,
      'detected_symptoms': detectedSymptoms,
      'answers': answers,
      'flags': flags,
      'is_urgent': isUrgent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ExaminationResult toEntity() {
    return ExaminationResult(
      score: score,
      percentage: percentage,
      riskLevel: riskLevel,
      validityStatus: isValid ? 'VALID' : 'TIDAK_VALID',
      recommendation: conclusion,
      detectedSymptoms: detectedSymptoms,
      flags: flags,
      isUrgent: isUrgent,
      answers: answers,
    );
  }
}
