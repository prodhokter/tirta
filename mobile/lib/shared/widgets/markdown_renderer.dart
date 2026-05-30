import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tirta/core/constants/app_colors.dart';

/// Custom markdown renderer for TIRTA chatbot and article content.
/// Parses common markdown syntax and renders as RichText widgets.
class MarkdownRenderer extends StatelessWidget {
  final String text;
  final Color? textColor;
  final double baseFontSize;
  final double lineHeight;
  final bool isChatBubble;

  const MarkdownRenderer({
    super.key,
    required this.text,
    this.textColor,
    this.baseFontSize = 14,
    this.lineHeight = 1.6,
    this.isChatBubble = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? AppColors.textPrimary;
    final blocks = _parseBlocks(text.trim());

    if (blocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) => _buildBlock(block, color)).toList(),
    );
  }

  Widget _buildBlock(_MarkdownBlock block, Color defaultColor) {
    switch (block.type) {
      case _BlockType.heading1:
        return Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
          child: Text.rich(
            _parseInline(block.content, defaultColor, bold: true, fontSize: (baseFontSize + 6).sp),
          ),
        );
      case _BlockType.heading2:
        return Padding(
          padding: EdgeInsets.only(top: 14.h, bottom: 6.h),
          child: Text.rich(
            _parseInline(block.content, defaultColor, bold: true, fontSize: (baseFontSize + 4).sp),
          ),
        );
      case _BlockType.heading3:
        return Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
          child: Text.rich(
            _parseInline(block.content, defaultColor, bold: true, fontSize: (baseFontSize + 2).sp),
          ),
        );
      case _BlockType.blockquote:
        return Container(
          margin: EdgeInsets.symmetric(vertical: 4.h),
          padding: EdgeInsets.only(left: 12.w),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.6),
                width: 3.w,
              ),
            ),
          ),
          child: Text.rich(
            _parseInline(block.content, defaultColor.withValues(alpha: 0.85), italic: true, fontSize: baseFontSize.sp),
          ),
        );
      case _BlockType.bulletList:
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.items!.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 2.h, left: 8.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      fontSize: baseFontSize.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      height: lineHeight,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text.rich(
                      _parseInline(item, defaultColor, fontSize: baseFontSize.sp),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        );
      case _BlockType.numberedList:
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.items!.asMap().entries.map((entry) => Padding(
              padding: EdgeInsets.only(bottom: 2.h, left: 4.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20.w,
                    child: Text(
                      '${entry.key + 1}.',
                      style: TextStyle(
                        fontSize: baseFontSize.sp,
                        color: defaultColor,
                        fontWeight: FontWeight.w600,
                        height: lineHeight,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      _parseInline(entry.value, defaultColor, fontSize: baseFontSize.sp),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        );
      case _BlockType.codeBlock:
        return Container(
          margin: EdgeInsets.symmetric(vertical: 6.h),
          padding: EdgeInsets.all(12.r),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text.rich(
            TextSpan(
              text: block.content,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: (baseFontSize - 1).sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        );
      case _BlockType.horizontalRule:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        );
      case _BlockType.paragraph:
        return Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Text.rich(
            _parseInline(block.content, defaultColor, fontSize: baseFontSize.sp),
          ),
        );
      case _BlockType.empty:
        return SizedBox(height: 4.h);
    }
  }

  /// Parse inline markdown: **bold**, *italic*, ~~strikethrough~~, `code`
  TextSpan _parseInline(
    String text,
    Color defaultColor, {
    bool bold = false,
    bool italic = false,
    double fontSize = 14,
  }) {
    final List<InlineSpan> spans = [];
    int i = 0;
    final len = text.length;

    while (i < len) {
      // Bold: **text** or __text__
      if ((text.startsWith('**', i) || text.startsWith('__', i)) && i + 2 < len) {
        final marker = text.substring(i, i + 2);
        final end = text.indexOf(marker, i + 2);
        if (end != -1) {
          final inner = text.substring(i + 2, end);
          spans.addAll(_parseInline(inner, defaultColor, bold: true, italic: italic, fontSize: fontSize).children ?? [
            TextSpan(text: inner, style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize.sp, color: defaultColor, height: lineHeight)),
          ]);
          i = end + 2;
          continue;
        }
      }

      // Italic: *text* or _text_ (but not ** or __)
      if (text[i] == '*' && (i == 0 || text[i - 1] != '*') && i + 1 < len && text[i + 1] != '*') {
        final end = text.indexOf('*', i + 1);
        if (end != -1 && (end == len - 1 || text[end + 1] != '*')) {
          final inner = text.substring(i + 1, end);
          spans.addAll(_parseInline(inner, defaultColor, bold: bold, italic: true, fontSize: fontSize).children ?? [
            TextSpan(text: inner, style: TextStyle(fontStyle: FontStyle.italic, fontSize: fontSize.sp, color: defaultColor, height: lineHeight)),
          ]);
          i = end + 1;
          continue;
        }
      }
      // Italic with underscore
      if (text[i] == '_' && (i == 0 || text[i - 1] != '_') && i + 1 < len && text[i + 1] != '_') {
        final end = text.indexOf('_', i + 1);
        if (end != -1 && (end == len - 1 || text[end + 1] != '_')) {
          final inner = text.substring(i + 1, end);
          spans.addAll(_parseInline(inner, defaultColor, bold: bold, italic: true, fontSize: fontSize).children ?? [
            TextSpan(text: inner, style: TextStyle(fontStyle: FontStyle.italic, fontSize: fontSize.sp, color: defaultColor, height: lineHeight)),
          ]);
          i = end + 1;
          continue;
        }
      }

      // Strikethrough: ~~text~~
      if (text.startsWith('~~', i) && i + 2 < len) {
        final end = text.indexOf('~~', i + 2);
        if (end != -1) {
          final inner = text.substring(i + 2, end);
          spans.add(TextSpan(
            text: inner,
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              fontSize: fontSize.sp,
              color: defaultColor.withValues(alpha: 0.7),
              height: lineHeight,
            ),
          ));
          i = end + 2;
          continue;
        }
      }

      // Inline code: `text`
      if (text[i] == '`') {
        final end = text.indexOf('`', i + 1);
        if (end != -1) {
          final code = text.substring(i + 1, end);
          spans.add(TextSpan(
            text: code,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: (fontSize - 1).sp,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              color: AppColors.primaryDark,
              height: lineHeight,
            ),
          ));
          i = end + 1;
          continue;
        }
      }

      // Plain text until next marker
      int next = i + 1;
      while (next < len) {
        if (text[next] == '*' || text[next] == '_' || text[next] == '~' || text[next] == '`') {
          break;
        }
        next++;
      }
      spans.add(TextSpan(
        text: text.substring(i, next),
        style: TextStyle(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontSize: fontSize.sp,
          color: defaultColor,
          height: lineHeight,
        ),
      ));
      i = next;
    }

    return TextSpan(children: spans.isEmpty ? null : spans);
  }

  List<_MarkdownBlock> _parseBlocks(String text) {
    final lines = text.split('\n');
    final List<_MarkdownBlock> blocks = [];
    int i = 0;

    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();

      // Empty line
      if (trimmed.isEmpty) {
        blocks.add(const _MarkdownBlock(type: _BlockType.empty));
        i++;
        continue;
      }

      // Code block: ``` ... ```
      if (trimmed.startsWith('```')) {
        final codeLines = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        blocks.add(_MarkdownBlock(type: _BlockType.codeBlock, content: codeLines.join('\n')));
        i++; // skip closing ```
        continue;
      }

      // Horizontal rule: --- or *** or ___
      if (trimmed == '---' || trimmed == '***' || trimmed == '___') {
        blocks.add(const _MarkdownBlock(type: _BlockType.horizontalRule));
        i++;
        continue;
      }

      // Heading: # ## ###
      if (trimmed.startsWith('### ')) {
        blocks.add(_MarkdownBlock(type: _BlockType.heading3, content: trimmed.substring(4)));
        i++;
        continue;
      }
      if (trimmed.startsWith('## ')) {
        blocks.add(_MarkdownBlock(type: _BlockType.heading2, content: trimmed.substring(3)));
        i++;
        continue;
      }
      if (trimmed.startsWith('# ')) {
        blocks.add(_MarkdownBlock(type: _BlockType.heading1, content: trimmed.substring(2)));
        i++;
        continue;
      }

      // Blockquote: >
      if (trimmed.startsWith('> ')) {
        blocks.add(_MarkdownBlock(type: _BlockType.blockquote, content: trimmed.substring(2)));
        i++;
        continue;
      }

      // Bullet list
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        final items = <String>[];
        while (i < lines.length && (lines[i].trim().startsWith('- ') || lines[i].trim().startsWith('* '))) {
          items.add(lines[i].trim().substring(2));
          i++;
        }
        blocks.add(_MarkdownBlock(type: _BlockType.bulletList, items: items));
        continue;
      }

      // Numbered list
      final numberedMatch = RegExp(r'^(\d+)\.\s').firstMatch(trimmed);
      if (numberedMatch != null) {
        final items = <String>[];
        int expectedNum = int.parse(numberedMatch.group(1)!);
        while (i < lines.length) {
          final currentMatch = RegExp(r'^(\d+)\.\s').firstMatch(lines[i].trim());
          if (currentMatch == null) break;
          final num = int.parse(currentMatch.group(1)!);
          if (num != expectedNum) break;
          items.add(lines[i].trim().substring(currentMatch.group(0)!.length));
          expectedNum++;
          i++;
        }
        blocks.add(_MarkdownBlock(type: _BlockType.numberedList, items: items));
        continue;
      }

      // Regular paragraph
      final paraLines = <String>[trimmed];
      i++;
      while (i < lines.length && lines[i].trim().isNotEmpty &&
             !lines[i].trim().startsWith('#') &&
             !lines[i].trim().startsWith('>') &&
             !lines[i].trim().startsWith('-') &&
             !lines[i].trim().startsWith('*') &&
             !lines[i].trim().startsWith('```') &&
             lines[i].trim() != '---' &&
             !RegExp(r'^\d+\.\s').hasMatch(lines[i].trim())) {
        paraLines.add(lines[i].trim());
        i++;
      }
      blocks.add(_MarkdownBlock(type: _BlockType.paragraph, content: paraLines.join(' ')));
    }

    return blocks;
  }
}

enum _BlockType {
  heading1,
  heading2,
  heading3,
  paragraph,
  blockquote,
  bulletList,
  numberedList,
  codeBlock,
  horizontalRule,
  empty,
}

class _MarkdownBlock {
  final _BlockType type;
  final String content;
  final List<String>? items;

  const _MarkdownBlock({
    required this.type,
    this.content = '',
    this.items,
  });
}
