import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/theme/text_styles.dart';
import 'package:tirta/core/utils/date_formatter.dart';
import 'package:tirta/features/chatbot/domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  bool get isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: 0.75.sw,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : AppColors.cardBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: isUser ? Radius.circular(16.r) : Radius.circular(4.r),
                bottomRight: isUser ? Radius.circular(4.r) : Radius.circular(16.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: SelectableText(
              message.content,
              style: TextStyles.bodyMedium.copyWith(
                color: isUser ? Colors.white : AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isUser ? 0 : 4.w,
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
}
