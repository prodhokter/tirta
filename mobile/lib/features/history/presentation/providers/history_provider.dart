import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tirta/features/expert_system/data/datasources/examination_remote_datasource.dart';
import 'package:tirta/features/expert_system/data/models/examination_model.dart';
import 'package:tirta/features/history/data/repositories/history_repository_impl.dart';

// --- State ---

class HistoryState {
  final List<ExaminationModel> examinations;
  final bool isLoading;
  final String? error;

  const HistoryState({
    this.examinations = const [],
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<ExaminationModel>? examinations,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      examinations: examinations ?? this.examinations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory HistoryState.initial() => const HistoryState();

  bool get isEmpty => examinations.isEmpty && !isLoading && error == null;
}

// --- Providers ---

final historyRepositoryProvider = Provider<HistoryRepositoryImpl>((ref) {
  return HistoryRepositoryImpl(ExaminationRemoteDatasource());
});

final historyNotifierProvider =
    StateNotifierProvider.autoDispose<HistoryNotifier, HistoryState>(
  (ref) {
    final repository = ref.watch(historyRepositoryProvider);
    return HistoryNotifier(repository);
  },
);

// --- Notifier ---

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepositoryImpl _repository;

  HistoryNotifier(this._repository) : super(HistoryState.initial()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final examinations = await _repository.getHistory();
      state = state.copyWith(
        examinations: examinations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> deleteExamination(String id) async {
    try {
      await _repository.deleteHistory(id);
      final updated = state.examinations
          .where((exam) => exam.id != id)
          .toList();
      state = state.copyWith(examinations: updated);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
