import 'package:tirta/features/expert_system/data/datasources/examination_remote_datasource.dart';
import 'package:tirta/features/expert_system/data/models/examination_model.dart';
import 'package:tirta/shared/services/supabase_service.dart';

class HistoryRepositoryImpl {
  final ExaminationRemoteDatasource _remoteDatasource;

  HistoryRepositoryImpl(this._remoteDatasource);

  Future<List<ExaminationModel>> getHistory() async {
    return await _remoteDatasource.getExaminationHistory();
  }

  Future<void> deleteHistory(String examinationId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await SupabaseService.client
        .from('examinations')
        .delete()
        .eq('id', examinationId)
        .eq('user_id', userId);
  }

  Future<ExaminationModel> getExaminationById(String examinationId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await SupabaseService.client
        .from('examinations')
        .select()
        .eq('id', examinationId)
        .eq('user_id', userId)
        .single();

    return ExaminationModel.fromJson(response);
  }
}
