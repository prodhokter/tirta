import 'package:tirta/features/expert_system/data/datasources/examination_remote_datasource.dart';
import 'package:tirta/features/expert_system/data/models/examination_model.dart';
import 'package:tirta/features/expert_system/domain/entities/examination_result.dart';
import 'package:tirta/features/expert_system/domain/repositories/examination_repository.dart';
import 'package:tirta/shared/services/supabase_service.dart';

class ExaminationRepositoryImpl implements ExaminationRepository {
  final ExaminationRemoteDatasource _remoteDatasource;

  ExaminationRepositoryImpl(this._remoteDatasource);

  @override
  Future<void> saveExamination(ExaminationResult result) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final model = ExaminationModel.fromResult(
      result: result,
      userId: userId,
    );
    await _remoteDatasource.saveExamination(model);
  }

  @override
  Future<List<ExaminationResult>> getExaminationHistory() async {
    final models = await _remoteDatasource.getExaminationHistory();
    return models.map((model) => model.toEntity()).toList();
  }
}
