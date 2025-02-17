import 'package:flutter/material.dart';
import '../../../data/models/tool.dart';

class ToolList extends StatelessWidget {
  final List<Tool> tools;

  const ToolList({Key? key, required this.tools}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return ExpansionTile(
          leading: tool.icon.isNotEmpty
              ? Image.network(tool.icon, width: 24, height: 24)
              : const Icon(Icons.extension),
          title: Text(tool.name),
          subtitle: Text(
            tool.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          children: tool.tools.map((function) {
            return ListTile(
              title: Text(function.name),
              subtitle: Text(function.description),
              leading: const Icon(Icons.functions),
              onTap: () {
                // TODO: 處理工具功能點擊
              },
            );
          }).toList(),
        );
      },
    );
  }
} 