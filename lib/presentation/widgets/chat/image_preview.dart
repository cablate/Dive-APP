/** 
 * dart:typed_data 提供了處理二進制數據的功能
 * 主要用於處理圖片的二進制數據（Uint8List）
 */
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/utils/file_helper.dart';

/**
 * ImagePreviewList 是一個用於顯示已選擇圖片預覽的Widget
 * 繼承自StatelessWidget，因為所有狀態都由外部傳入和管理
 */
class ImagePreviewList extends StatelessWidget {
  /** 
   * selectedFiles: 儲存已選擇圖片的base64字串列表
   * onRemove: 當使用者點擊刪除按鈕時的回調函數
   */
  final List<String> selectedFiles;
  final Function(String) onRemove;

  /** 
   * 建構函數
   * required 關鍵字表示這些參數是必須的，不能為null
   */
  const ImagePreviewList({
    super.key,
    required this.selectedFiles,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    /** 
     * SizedBox用於限制預覽列表的高度為120像素
     */
    return SizedBox(
      height: 120,
      /** 
       * ListView.builder 用於建立可滾動的列表
       * 當項目較多時，只會建立可見區域內的項目，提升效能
       */
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // 設置為水平滾動
        itemCount: selectedFiles.length, // 列表項目數量
        itemBuilder: (context, index) {
          /** 
           * Padding 用於添加內邊距
           * 每個預覽圖的右側有8.0像素的間距
           */
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            /** 
             * Stack 允許子Widget相互重疊
             * 用於在圖片上方顯示關閉按鈕
             */
            child: Stack(
              children: [
                /** 
                 * FutureBuilder 用於處理非同步操作
                 * 在這裡用於將base64字串轉換為圖片數據
                 */
                FutureBuilder<Uint8List?>(
                  future: FileHelper.base64ToBytes(selectedFiles[index]),
                  builder: (context, snapshot) {
                    /** 
                     * 當數據還未準備好時，顯示載入指示器
                     */
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        width: 120,
                        height: 120,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    /** 
                     * 使用Image.memory顯示圖片
                     * 直接從記憶體中的二進制數據顯示圖片
                     */
                    return Image.memory(
                      snapshot.data!,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover, // 圖片填充模式，確保圖片完全覆蓋指定區域
                    );
                  },
                ),
                /** 
                 * Positioned 用於在Stack中精確定位Widget
                 * 這裡將關閉按鈕放在右上角
                 */
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        onRemove(selectedFiles[index]), // 點擊時調用onRemove回調
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
