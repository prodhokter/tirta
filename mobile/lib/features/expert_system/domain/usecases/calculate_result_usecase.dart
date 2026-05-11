import 'package:tirta/features/expert_system/data/models/question_model.dart';
import 'package:tirta/features/expert_system/domain/entities/examination_result.dart';

class CalculateResultUsecase {
  ExaminationResult call(List<bool> answers) {
    if (answers.length != 15) {
      throw ArgumentError('Expected 15 answers, got ${answers.length}');
    }

    final int score = answers.where((a) => a).length;
    final double percentage = (score / 15) * 100;

    // Count systemic symptoms (indices 4,5,6,7,8)
    final int systemicCount =
        [answers[4], answers[5], answers[6], answers[7], answers[8]]
            .where((a) => a)
            .length;

    // Count risk factors (indices 9,10,11,12)
    final int riskFactorCount =
        [answers[9], answers[10], answers[11], answers[12]]
            .where((a) => a)
            .length;

    // Forward chaining rules
    bool suspectMainSymptom = false;
    bool riskSedang = false;
    bool riskTinggi = false;

    // Rule 1: IF answers[0] OR answers[1] OR answers[14] -> suspect_main_symptom
    if (answers[0] || answers[1] || answers[14]) {
      suspectMainSymptom = true;
    }

    // Rule 2: IF suspect_main_symptom AND systemic_count >= 2 -> risk_sedang
    if (suspectMainSymptom && systemicCount >= 2) {
      riskSedang = true;
    }

    // Rule 3: IF suspect_main_symptom AND systemic_count >= 3 -> risk_tinggi
    if (suspectMainSymptom && systemicCount >= 3) {
      riskTinggi = true;
    }

    // Rule 4: IF risk_tinggi AND risk_factor_count >= 1 -> TERINDIKASI_TBC
    bool terindikasiTbc = riskTinggi && riskFactorCount >= 1;

    // Determine conclusion and risk level
    String conclusion;
    String riskLevel;

    if (terindikasiTbc) {
      conclusion =
          'TERINDIKASI TBC -- Segera konsultasi ke dokter atau puskesmas terdekat';
      riskLevel = 'tinggi';
    } else if (riskTinggi) {
      conclusion =
          'SUSPEK TBC -- Dianjurkan untuk segera memeriksakan diri ke puskesmas';
      riskLevel = 'tinggi';
    } else if (riskSedang) {
      conclusion =
          'RISIKO SEDANG -- Pantau gejala dan konsultasi jika memburuk';
      riskLevel = 'sedang';
    } else {
      conclusion = 'RISIKO RENDAH -- Tetap jaga pola hidup sehat';
      riskLevel = 'rendah';
    }

    // Override risk level based on percentage if forward chaining says lower
    if (percentage >= 60 && riskLevel != 'tinggi') {
      riskLevel = 'tinggi';
    } else if (percentage >= 30 && riskLevel == 'rendah') {
      riskLevel = 'sedang';
    }

    // Collect detected symptoms
    const questions = QuestionModel.questions;
    final List<String> detectedSymptoms = [];
    for (int i = 0; i < 15; i++) {
      if (answers[i]) {
        detectedSymptoms.add(questions[i].text);
      }
    }

    final bool isValid = score >= 5;

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
