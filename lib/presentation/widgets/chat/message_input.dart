/** 
 * dart:typed_data 用於處理二進制數據
 * 在這裡用於處理圖片檔案
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcp_chat/core/utils/file_helper.dart';
import 'package:mcp_chat/presentation/blocs/chat/chat_bloc.dart';
import 'package:mcp_chat/presentation/blocs/chat/chat_event.dart';

import 'image_preview.dart';

/**
 * MessageInput 是一個有狀態的Widget
 * 需要管理輸入框的文字內容和已選擇的圖片
 */
class MessageInput extends StatefulWidget {
  const MessageInput({super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

/**
 * _MessageInputState 管理 MessageInput 的狀態
 * 包含文字輸入、圖片選擇和上傳等功能
 */
class _MessageInputState extends State<MessageInput> {
  /** 
   * _controller: 用於控制文字輸入框的內容
   * _imagePicker: 用於選擇圖片的工具
   * _selectedFiles: 儲存已選擇的圖片（base64格式）
   * _isUploading: 標記是否正在上傳圖片
   */
  final TextEditingController _controller = TextEditingController();
  final _imagePicker = ImagePicker();
  List<String> _selectedFiles = [];
  bool _isUploading = false;

  /** 
   * dispose 方法在 Widget 被銷毀時調用
   * 用於釋放資源，避免記憶體洩漏
   */
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /** 
   * _pickImage 方法處理圖片選擇功能
   * 使用 image_picker 套件從相簿選擇圖片
   * 選擇後將圖片轉換為 base64 格式儲存
   */
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _isUploading = true;
        });

        final base64String = await FileHelper.imageToBase64(image);

        setState(() {
          _selectedFiles = [..._selectedFiles, base64String];
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      debugPrint('選擇圖片時發生錯誤: $e');
    }
  }

  /** 
   * _removeFile 方法用於移除已選擇的圖片
   * 從 _selectedFiles 列表中過濾掉指定的圖片
   */
  void _removeFile(String path) {
    setState(() {
      _selectedFiles = _selectedFiles.where((file) => file != path).toList();
    });
  }

  void _handleSubmit() {
    if (_controller.text.trim().isEmpty) return;

    // 收起鍵盤
    FocusScope.of(context).unfocus();

    // 發送訊息
    context.read<ChatBloc>().add(SendMessage(
          message: _controller.text,
          files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
        ));

    // 清空輸入框和已選檔案
    _controller.clear();
    setState(() {
      _selectedFiles = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    /** 
     * Container 用於創建一個帶有裝飾的容器
     * 包含內邊距和上邊框
     */
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      /** 
       * Column 垂直排列子Widget
       * 包含圖片預覽列表和輸入區域
       */
      child: Column(
        children: [
          /** 
           * 當有選擇圖片時，顯示圖片預覽列表
           */
          if (_selectedFiles.isNotEmpty)
            ImagePreviewList(
              selectedFiles: _selectedFiles,
              onRemove: _removeFile,
            ),
          /** 
           * Row 水平排列輸入區域的各個元素
           * 包含：附加檔案按鈕、文字輸入框、發送按鈕
           */
          Row(
            children: [
              /** 
               * 附加檔案按鈕
               * 上傳中顯示進度指示器，否則顯示附加圖示
               */
              IconButton(
                icon: _isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
                onPressed: _pickImage,
                tooltip: '附加圖片',
              ),
              /** 
               * Expanded 讓文字輸入框佔據剩餘的水平空間
               */
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '輸入訊息...',
                    border: InputBorder.none,
                  ),
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                ),
              ),
              const SizedBox(width: 8), // 間距
              /** 
               * 發送按鈕
               */
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _handleSubmit,
                tooltip: '發送',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
