import 'package:tirta/features/expert_system/data/models/examination_model.dart';
import 'package:tirta/shared/services/supabase_service.dart';

class ExaminationRemoteDatasource {
  Future<void> saveExamination(ExaminationModel model) async {
    await SupabaseService.client.from('examinations').insert(model.toJson());
  }

  Future<List<ExaminationModel>> getExaminationHistory() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    final response = await SupabaseService.client
        .from('examinations')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ExaminationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
