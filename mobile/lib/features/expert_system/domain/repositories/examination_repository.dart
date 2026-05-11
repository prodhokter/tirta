import 'package:tirta/features/expert_system/domain/entities/examination_result.dart';

abstract class ExaminationRepository {
  Future<void> saveExamination(ExaminationResult result);
  Future<List<ExaminationResult>> getExaminationHistory();
}
