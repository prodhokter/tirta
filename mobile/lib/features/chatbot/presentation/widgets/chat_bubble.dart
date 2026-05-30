import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/theme/text_styles.dart';
import 'package:tirta/core/utils/date_formatter.dart';
import 'package:tirta/features/chatbot/domain/entities/chat_message.dart';
import 'package:tirta/shared/widgets/markdown_renderer.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;
  final bool isError;
  final bool isAuthError;

  const ChatBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.isError = false,
    this.isAuthError = false,
  });

  bool get isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Copy/retry button for AI messages
              if (!isUser && !isStreaming && message.content.isNotEmpty)
                _buildActionButton(),
              Flexible(child: _buildBubble(context)),
            ],
          ),
          if (!isStreaming)
            Padding(
              padding: EdgeInsets.only(
                top: 4.h,
                right: isUser ? 4.w : 0,
                left: isUser ? 0 : 4.w,
              ),
              child: Text(
                message.createdAt != null
                    ? DateFormatter.formatTime(message.createdAt!)
                    : '',
                style: TextStyles.caption.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.textHint,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: EdgeInsets.only(right: 6.w, bottom: 4.h),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: message.content));
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 28.w,
          height: 28.h,
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Icon(
            (isError || isAuthError) ? Icons.error_outline : Icons.copy_rounded,
            size: 14.sp,
            color: (isError || isAuthError) ? AppColors.error : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final hasError = isError || isAuthError;
    final bgColor = hasError
        ? AppColors.riskHighRed.withValues(alpha: 0.3)
        : isUser
            ? AppColors.primary
            : AppColors.cardBg;

    final borderColor = hasError ? AppColors.error.withValues(alpha: 0.4) : AppColors.divider;

    return Container(
      constraints: BoxConstraints(maxWidth: isUser ? 0.7.sw : 0.85.sw),
      padding: EdgeInsets.symmetric(
        horizontal: isUser ? 14.w : 14.w,
        vertical: isUser ? 10.h : 12.h,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        border: (isUser && !hasError) ? null : Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isUser ? 0.08 : 0.04),
            blurRadius: isUser ? 6 : 4,
            offset: Offset(0, isUser ? 2.h : 1.h),
          ),
        ],
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isStreaming && message.content.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(0, 0),
          SizedBox(width: 4.w),
          _buildDot(1, 150),
          SizedBox(width: 4.w),
          _buildDot(2, 300),
        ],
      );
    }

    if (isUser) {
      return SelectableText(
        message.content,
        style: TextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      );
    }

    if (isAuthError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 16.sp, color: AppColors.error),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Login Ulang',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (isError) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16.sp, color: AppColors.error),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MarkdownRenderer(
          text: message.content,
          baseFontSize: 13.5,
          lineHeight: 1.6,
          isChatBubble: true,
        ),
        if (isStreaming)
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: _buildCursor(),
          ),
      ],
    );
  }

  Widget _buildDot(int index, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: value),
          ),
        );
      },
    );
  }

  Widget _buildCursor() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.2, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 2.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: value),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
    );
  }
}
