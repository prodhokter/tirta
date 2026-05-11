import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tirta/features/expert_system/data/datasources/examination_remote_datasource.dart';
import 'package:tirta/features/expert_system/data/repositories/examination_repository_impl.dart';
import 'package:tirta/features/expert_system/domain/entities/examination_result.dart';
import 'package:tirta/features/expert_system/domain/entities/question.dart';
import 'package:tirta/features/expert_system/domain/usecases/calculate_result_usecase.dart';
import 'package:tirta/features/expert_system/domain/usecases/get_questions_usecase.dart';
import 'package:tirta/features/expert_system/domain/usecases/save_examination_usecase.dart';

class ExpertSystemState {
  final int currentQuestionIndex;
  final List<bool> answers;
  final bool isLoading;
  final String? error;
  final ExaminationResult? result;
  final List<Question> questions;

  const ExpertSystemState({
    this.currentQuestionIndex = 0,
    this.answers = const [],
    this.isLoading = false,
    this.error,
    this.result,
    this.questions = const [],
  });

  ExpertSystemState copyWith({
    int? currentQuestionIndex,
    List<bool>? answers,
    bool? isLoading,
    String? error,
    ExaminationResult? result,
    List<Question>? questions,
  }) {
    return ExpertSystemState(
      currentQuestionIndex:
          currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
      questions: questions ?? this.questions,
    );
  }

  bool get isLastQuestion => currentQuestionIndex >= questions.length - 1;
  bool get isComplete => answers.length >= questions.length;
}

class ExpertSystemNotifier extends StateNotifier<ExpertSystemState> {
  final GetQuestionsUsecase _getQuestionsUsecase;
  final CalculateResultUsecase _calculateResultUsecase;
  final SaveExaminationUsecase _saveExaminationUsecase;
  final ExaminationRepositoryImpl _repository;

  ExpertSystemNotifier()
      : _getQuestionsUsecase = GetQuestionsUsecase(),
        _calculateResultUsecase = CalculateResultUsecase(),
        _saveExaminationUsecase = SaveExaminationUsecase(),
        _repository = ExaminationRepositoryImpl(
          ExaminationRemoteDatasource(),
        ),
        super(const ExpertSystemState()) {
    _loadQuestions();
  }

  void _loadQuestions() {
    final questions = _getQuestionsUsecase();
    state = state.copyWith(questions: questions);
  }

  void startExamination() {
    state = const ExpertSystemState(
      currentQuestionIndex: 0,
      answers: [],
      isLoading: false,
      error: null,
      result: null,
      questions: [],
    );
    _loadQuestions();
  }

  void answerQuestion(bool answer) {
    final List<bool> updatedAnswers = List.from(state.answers);

    if (state.currentQuestionIndex < updatedAnswers.length) {
      updatedAnswers[state.currentQuestionIndex] = answer;
    } else {
      updatedAnswers.add(answer);
    }

    if (!state.isLastQuestion) {
      state = state.copyWith(
        answers: updatedAnswers,
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    } else {
      state = state.copyWith(answers: updatedAnswers);
    }
  }

  void goToPreviousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  void calculateAndSaveResult() {
    if (state.answers.length < 15) return;

    final result = _calculateResultUsecase(state.answers);
    state = state.copyWith(result: result);

    saveToSupabase();
  }

  Future<void> saveToSupabase() async {
    if (state.result == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _saveExaminationUsecase(state.result!);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<List<ExaminationResult>> getExaminationHistory() async {
    try {
      return await _repository.getExaminationHistory();
    } catch (e) {
      return [];
    }
  }
}

final expertSystemProvider =
    StateNotifierProvider<ExpertSystemNotifier, ExpertSystemState>(
  (ref) => ExpertSystemNotifier(),
);
