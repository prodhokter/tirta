import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/core/theme/text_styles.dart';
import 'package:tirta/features/chatbot/presentation/providers/chat_provider.dart';
import 'package:tirta/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:tirta/features/chatbot/presentation/widgets/chat_input_field.dart';
import 'package:tirta/features/chatbot/presentation/widgets/quick_reply_buttons.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  bool _showScrollDown = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadChatHistory();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.hasClients &&
        _scrollController.position.pixels <
            _scrollController.position.maxScrollExtent - 200;
    if (show != _showScrollDown) {
      setState(() => _showScrollDown = show);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(String text) {
    HapticFeedback.lightImpact();
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _handleQuickReply(String text) {
    HapticFeedback.lightImpact();
    ref.read(chatProvider.notifier).sendMessageWithQuickReply(text);
    _scrollToBottom();
  }

  Future<void> _handleClearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(AppStrings.chatClear, style: TextStyles.titleMedium),
        content: Text(
          AppStrings.chatClearConfirm,
          style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel,
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(AppStrings.chatClear, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(chatProvider.notifier).clearChat();
    }
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);
    if (msgDate == today) return 'Hari ini';
    if (msgDate == today.subtract(const Duration(days: 1))) return 'Kemarin';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          (previous?.messages.isNotEmpty == true &&
              next.messages.isNotEmpty &&
              previous!.messages.last.content != next.messages.last.content)) {
        _scrollToBottom();
      }
    });

    // Pulse animation when streaming
    if (chatState.isStreaming) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    final hasMessages = chatState.messages.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(chatState),
      body: Column(
        children: [
          QuickReplyButtons(
            isEnabled: !chatState.isLoading,
            onTap: _handleQuickReply,
          ),
          Expanded(
            child: Stack(
              children: [
                if (chatState.isLoading && !hasMessages)
                  _buildLoadingState()
                else if (!hasMessages)
                  _buildWelcomeState()
                else
                  _buildMessageList(chatState),
                if (_showScrollDown && hasMessages)
                  Positioned(
                    bottom: 8.h,
                    right: 16.w,
                    child: _buildScrollDownButton(),
                  ),
              ],
            ),
          ),
          if (hasMessages) _buildDisclaimerBar(),
          ChatInputField(
            isEnabled: !chatState.isLoading,
            onSubmitted: _handleSendMessage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatState chatState) {
    final isStreaming = chatState.isStreaming;
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.cardBg,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 4,
      leading: Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = isStreaming ? _pulseController.value : 0.0;
            return Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08 + pulse * 0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: isStreaming
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2 + pulse * 0.3),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                color: AppColors.primary,
                size: 22.sp,
              ),
            );
          },
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TIRTA Assistant',
            style: TextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          if (isStreaming)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStreamingDot(0),
                SizedBox(width: 3.w),
                _buildStreamingDot(1),
                SizedBox(width: 3.w),
                _buildStreamingDot(2),
                SizedBox(width: 6.w),
                Text(
                  AppStrings.chatTyping,
                  style: TextStyle(fontSize: 10.sp, color: AppColors.primary),
                ),
              ],
            )
          else if (chatState.messages.isNotEmpty)
            Text(
              '${chatState.messages.length} ${AppStrings.chatMessageCount}',
              style: TextStyles.caption.copyWith(
                fontSize: 10.sp,
                color: AppColors.textHint,
              ),
            ),
        ],
      ),
      actions: [
        if (chatState.messages.isNotEmpty)
          IconButton(
            onPressed: _handleClearChat,
            icon: Icon(Icons.add_comment_outlined,
                size: 20.sp, color: AppColors.textSecondary),
            tooltip: AppStrings.chatNewChat,
          ),
        if (chatState.messages.isNotEmpty && !isStreaming)
          IconButton(
            onPressed: () => ref.read(chatProvider.notifier).retryLastMessage(),
            icon: Icon(Icons.refresh_rounded,
                size: 20.sp, color: AppColors.textSecondary),
            tooltip: 'Ulangi jawaban',
          ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildStreamingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: Duration(milliseconds: 450 + (index * 200)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 5.r,
          height: 5.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: value),
          ),
        );
      },
    );
  }

  Widget _buildScrollDownButton() {
    return Material(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: _scrollToBottom,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36.r,
          height: 36.r,
          alignment: Alignment.center,
          child: Icon(Icons.keyboard_arrow_down_rounded,
              size: 22.sp, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDisclaimerBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      color: AppColors.accent.withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 13.sp, color: AppColors.textHint),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              AppStrings.chatDisclaimer,
              style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                  height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08 * value),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.smart_toy_outlined, size: 40.sp,
                    color: AppColors.primary.withValues(alpha: value)),
              );
            },
          ),
          SizedBox(height: 24.h),
          Text('Memuat percakapan...',
              style: TextStyles.bodySmall.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    final suggestions = [
      ('Apa itu TBC?', Icons.help_outline, 'Pengertian dasar'),
      ('Gejala TBC', Icons.healing_outlined, 'Tanda-tanda TBC'),
      ('Cara penularan', Icons.air, 'Cara TBC menyebar'),
      ('Pengobatan TBC', Icons.medical_services_outlined, 'OAT dan DOTS'),
      ('Pencegahan TBC', Icons.shield_outlined, 'Lindungi diri'),
      ('Nutrisi untuk TBC', Icons.restaurant, 'Gizi pemulihan'),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 32.h),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.smart_toy_outlined,
                      size: 48.sp, color: AppColors.primary),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          Text(
            AppStrings.chatWelcome,
            style: TextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          Text(
            AppStrings.chatWelcomeSub,
            style: TextStyles.bodySmall.copyWith(fontSize: 13.sp, height: 1.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 28.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Topik yang bisa ditanyakan:',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 12.h),
          ...suggestions.map((s) => _buildSuggestionCard(s.$1, s.$2, s.$3)),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18.sp, color: AppColors.textHint),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    AppStrings.chatDisclaimer,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String title, IconData icon, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: () => _handleQuickReply(title),
          borderRadius: BorderRadius.circular(12.r),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 18.sp, color: AppColors.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 2.h),
                      Text(subtitle,
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textHint)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 18.sp, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatState chatState) {
    final messages = chatState.messages;

    // Build items with date separators
    final List<Widget> items = [];
    DateTime? lastDate;

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final msgDate = message.createdAt;

      if (msgDate != null) {
        final day = DateTime(msgDate.year, msgDate.month, msgDate.day);
        if (lastDate == null || day != lastDate) {
          lastDate = day;
          items.add(
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.divider.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    _getDateLabel(msgDate),
                    style: TextStyle(fontSize: 10.sp, color: AppColors.textHint,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          );
        }
      }

      final isLast = i == messages.length - 1;
      final isStreaming = chatState.isStreaming && isLast && message.role == 'assistant';
      final isError = message.role == 'assistant' &&
          (message.content.startsWith('Gagal') || message.content.startsWith('Maaf, terjadi') || message.content.startsWith('Respons server') || message.content.startsWith('Server sedang') || message.content.startsWith('Terlalu banyak'));
      final isAuthError = message.role == 'assistant' &&
          message.content.startsWith('Sesi kamu berakhir');

      items.add(
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12.h * (1 - value)),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: message.role == 'assistant' ? 0 : 32.w,
                    right: message.role == 'user' ? 0 : 16.w,
                  ),
                  child: ChatBubble(
                    message: message,
                    isStreaming: isStreaming,
                    isError: isError,
                    isAuthError: isAuthError,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}
