import 'package:tirta/features/expert_system/data/datasources/examination_remote_datasource.dart';
import 'package:tirta/features/expert_system/data/models/examination_model.dart';
import 'package:tirta/features/history/data/repositories/history_repository_impl.dart';

class GetExaminationHistoryUsecase {
  Future<List<ExaminationModel>> call() async {
    final repository = HistoryRepositoryImpl(
      ExaminationRemoteDatasource(),
    );
    return repository.getHistory();
  }
}
