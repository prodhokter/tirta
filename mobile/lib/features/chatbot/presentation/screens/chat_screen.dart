import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tirta/core/constants/app_colors.dart';
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

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadChatHistory();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _handleQuickReply(String text) {
    ref.read(chatProvider.notifier).sendMessageWithQuickReply(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          (previous?.messages.isNotEmpty == true && next.messages.isNotEmpty &&
           previous!.messages.last.content != next.messages.last.content)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          'TIRTA Assistant',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 24.sp,
          ),
          onPressed: null,
          tooltip: 'Chatbot',
        ),
      ),
      body: Column(
        children: [
          // Quick reply buttons at top
          QuickReplyButtons(
            isEnabled: !chatState.isLoading,
            onTap: _handleQuickReply,
          ),

          // Messages list
          Expanded(
            child: chatState.isLoading && chatState.messages.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : chatState.messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(chatState),
          ),

          // Typing indicator
          if (chatState.isStreaming && chatState.messages.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 14.r,
                    height: 14.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Mengetik...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textHint,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Input field at bottom
          ChatInputField(
            isEnabled: !chatState.isLoading,
            onSubmitted: _handleSendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64.sp,
              color: AppColors.textHint,
            ),
            SizedBox(height: 16.h),
            Text(
              'Halo! Saya TIRTA Assistant.',
              style: TextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Tanyakan apa saja tentang TBC, dan saya akan membantu menjawab pertanyaan kamu.',
              style: TextStyles.bodySmall.copyWith(
                fontSize: 13.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatState chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        return Align(
          alignment: message.role == 'user'
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: ChatBubble(
            message: message,
            isStreaming: chatState.isStreaming &&
                index == chatState.messages.length - 1 &&
                message.role == 'assistant',
          ),
        );
      },
    );
  }
}
