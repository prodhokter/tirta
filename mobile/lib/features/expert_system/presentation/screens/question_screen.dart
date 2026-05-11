import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/features/expert_system/presentation/providers/expert_system_provider.dart';
import 'package:tirta/features/expert_system/presentation/widgets/answer_button.dart';
import 'package:tirta/features/expert_system/presentation/widgets/progress_indicator.dart';
import 'package:tirta/features/expert_system/presentation/widgets/question_card.dart';

class QuestionScreen extends ConsumerWidget {
  const QuestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expertSystemProvider);
    final notifier = ref.read(expertSystemProvider.notifier);

    final currentIndex = state.currentQuestionIndex;
    final totalQuestions = state.questions.length;

    // Check if all questions answered
    if (state.answers.length >= totalQuestions && state.result == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.calculateAndSaveResult();
        context.pushReplacement(AppRoutes.result);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          '${AppStrings.question} ${currentIndex + 1} ${AppStrings.of} $totalQuestions',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => notifier.goToPreviousQuestion(),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              // Progress indicator
              ExpertProgressIndicator(
                current: currentIndex + 1,
                total: totalQuestions,
              ),
              SizedBox(height: 32.h),
              // Question card
              if (state.questions.isNotEmpty && currentIndex < totalQuestions)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QuestionCard(
                        question: state.questions[currentIndex],
                        questionNumber: currentIndex + 1,
                        totalQuestions: totalQuestions,
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 32.h),
              // Answer buttons
              if (state.questions.isNotEmpty && currentIndex < totalQuestions)
                Row(
                  children: [
                    Expanded(
                      child: AnswerButton(
                        text: AppStrings.yes,
                        isYes: true,
                        isSelected: currentIndex < state.answers.length &&
                            state.answers[currentIndex] == true,
                        onPressed: () => notifier.answerQuestion(true),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: AnswerButton(
                        text: AppStrings.no,
                        isYes: false,
                        isSelected: currentIndex < state.answers.length &&
                            state.answers[currentIndex] == false,
                        onPressed: () => notifier.answerQuestion(false),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
