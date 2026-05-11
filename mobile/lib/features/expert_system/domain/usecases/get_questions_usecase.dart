import 'package:tirta/features/expert_system/data/models/question_model.dart';
import 'package:tirta/features/expert_system/domain/entities/question.dart';

class GetQuestionsUsecase {
  List<Question> call() {
    return QuestionModel.questions;
  }
}
