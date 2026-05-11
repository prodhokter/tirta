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
  final List<bool> answers;
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
      conclusion: result.conclusion,
      detectedSymptoms: result.detectedSymptoms,
      answers: result.answers,
      createdAt: DateTime.now(),
    );
  }

  factory ExaminationModel.fromJson(Map<String, dynamic> json) {
    return ExaminationModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      score: json['score'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      isValid: json['is_valid'] as bool,
      conclusion: json['conclusion'] as String,
      detectedSymptoms: List<String>.from(json['detected_symptoms'] as List),
      answers: List<bool>.from(json['answers'] as List),
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
      'created_at': createdAt.toIso8601String(),
    };
  }

  ExaminationResult toEntity() {
    return ExaminationResult(
      score: score,
      percentage: percentage,
      riskLevel: riskLevel,
      isValid: isValid,
      conclusion: conclusion,
      detectedSymptoms: detectedSymptoms,
      answers: answers,
    );
  }
}
