/** 
 * dart:typed_data 用於處理二進制數據
 * 主要用於處理圖片的二進制格式
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mcp_chat/core/constants/api_constants.dart';
import 'package:mcp_chat/domain/entities/chat_message.dart';

/**
 * ChatMessageItem 是聊天訊息的顯示元件
 * 可以顯示文字、圖片、工具呼叫和工具結果
 * 支援使用者和AI助手兩種不同的訊息樣式
 */
class ChatMessageItem extends StatefulWidget {
  /** 
   * message: 包含訊息的所有資訊（內容、角色、檔案等）
   * isLoading: 標示訊息是否正在載入中
   */
  final ChatMessage message;
  final bool isLoading;

  const ChatMessageItem({
    super.key,
    required this.message,
    this.isLoading = false,
  });

  @override
  State<ChatMessageItem> createState() => _ChatMessageItemState();
}

/**
 * _ChatMessageItemState 管理訊息項目的狀態
 * 主要處理工具呼叫和結果的展開/收合狀態
 */
class _ChatMessageItemState extends State<ChatMessageItem> {
  /** 
   * _isToolCallsExpanded: 控制工具呼叫區塊的展開狀態
   * _isToolResultExpanded: 控制工具結果區塊的展開狀態
   */
  bool _isToolCallsExpanded = false;
  bool _isToolResultExpanded = false;

  bool _isImageFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  bool _isBase64Image(String path) {
    return path.startsWith('data:image');
  }

  Widget _buildFilePreview(String filePath) {
    // 處理 base64 圖片（尚未上傳的圖片）
    if (_isBase64Image(filePath)) {
      final imageData = filePath.split(',')[1];
      return Image.memory(
        base64Decode(imageData),
        height: 120,
        width: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[200],
            child: const Icon(Icons.error_outline),
          );
        },
      );
    }

    // 處理已上傳的圖片
    if (_isImageFile(filePath)) {
      return Image.network(
        '${ApiConstants.baseUrl}/uploads/$filePath',
        height: 120,
        width: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 120,
            height: 120,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[200],
            child: const Icon(Icons.error_outline),
          );
        },
      );
    }

    // 非圖片檔案的簡單預覽
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, size: 32),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              filePath.split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 圖片
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: _isBase64Image(filePath)
                  ? Image.memory(
                      base64Decode(filePath.split(',')[1]),
                      fit: BoxFit.contain,
                    )
                  : Image.network(
                      '${ApiConstants.baseUrl}/uploads/$filePath',
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
            ),
            // 關閉按鈕
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /** 
     * 判斷訊息是來自使用者還是AI助手
     * 用於決定訊息的樣式和位置
     */
    final isUser = widget.message.role == 'user';

    /** 
     * Container 作為最外層容器
     * 控制訊息的位置和間距
     */
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      /** 
       * ConstrainedBox 限制訊息氣泡的最大寬度
       * 設為螢幕寬度的 80%
       */
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        /** 
         * 訊息氣泡的主容器
         * 包含背景顏色和圓角效果
         */
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isUser ? 12 : 0),
              bottomRight: Radius.circular(isUser ? 0 : 12),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // 檔案/圖片預覽（始終在最上方）
              if (widget.message.files != null &&
                  widget.message.files!.isNotEmpty) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: isUser,
                  child: IntrinsicHeight(
                    child: Row(
                      children: widget.message.files!.map((filePath) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: isUser ? 8.0 : 0.0,
                            right: isUser ? 0.0 : 8.0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (_isImageFile(filePath) ||
                                  _isBase64Image(filePath)) {
                                _showImagePreview(context, filePath);
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildFilePreview(filePath),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // 訊息內容
              if (widget.message.content.isNotEmpty)
                MarkdownBody(
                  data: widget.message.content,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: Colors.black87),
                  ),
                ),

              // 工具呼叫和結果（在訊息內容之後）
              if (!isUser && widget.message.toolCalls != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isToolCallsExpanded = !_isToolCallsExpanded;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.build,
                        color: isUser ? Colors.white70 : Colors.black54,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '工具呼叫',
                        style: TextStyle(
                          color: isUser ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        _isToolCallsExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: isUser ? Colors.white70 : Colors.black54,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                if (_isToolCallsExpanded) ...[
                  const SizedBox(height: 8),
                  ...widget.message.toolCalls!.map((toolCall) => Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toolCall.name,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              toolCall.arguments.toString(),
                              style: TextStyle(
                                color: isUser ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
              if (!isUser && widget.message.toolResult != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isToolResultExpanded = !_isToolResultExpanded;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: isUser ? Colors.white70 : Colors.black54,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '工具結果',
                        style: TextStyle(
                          color: isUser ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        _isToolResultExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: isUser ? Colors.white70 : Colors.black54,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                if (_isToolResultExpanded) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.toolResult!.name,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message.toolResult!.result.toString(),
                          style: TextStyle(
                            color: isUser ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              // 載入指示器（在最下方）
              if (widget.isLoading) ...[
                const SizedBox(height: 8),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
