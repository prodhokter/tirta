import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_strings.dart';

class ChatInputField extends StatefulWidget {
  final bool isEnabled;
  final ValueChanged<String> onSubmitted;

  const ChatInputField({
    super.key,
    required this.isEnabled,
    required this.onSubmitted,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.isEnabled) return;

    HapticFeedback.lightImpact();
    widget.onSubmitted(text);
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    final sendActive = _hasText && widget.isEnabled;

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, -2.h),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.isEnabled,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => _handleSubmit(),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: AppStrings.chatPlaceholder,
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: AppColors.bgLight,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22.r),
                    borderSide: const BorderSide(
                      color: AppColors.primaryLight,
                      width: 1.5,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: sendActive ? AppColors.primary : AppColors.bgLight,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: sendActive ? AppColors.primary : AppColors.divider,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: sendActive ? _handleSubmit : null,
                  borderRadius: BorderRadius.circular(14.r),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.send_rounded,
                        key: ValueKey(sendActive),
                        color: sendActive ? Colors.white : AppColors.textHint,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
