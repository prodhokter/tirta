import 'package:tirta/features/expert_system/data/datasources/examination_remote_datasource.dart';
import 'package:tirta/features/expert_system/data/repositories/examination_repository_impl.dart';
import 'package:tirta/features/expert_system/domain/entities/examination_result.dart';
import 'package:tirta/shared/services/supabase_service.dart';

class SaveExaminationUsecase {
  final ExaminationRepositoryImpl _repository;

  SaveExaminationUsecase()
      : _repository = ExaminationRepositoryImpl(
          ExaminationRemoteDatasource(),
        );

  Future<void> call(ExaminationResult result) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _repository.saveExamination(result);
  }
}
