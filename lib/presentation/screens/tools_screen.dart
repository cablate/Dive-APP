import 'package:flutter/material.dart';

import '../../data/models/tool.dart';
import '../../data/providers/tool_provider.dart';
import '../widgets/tools/tool_list.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  late Future<List<Tool>> _toolsFuture;
  final _toolProvider = ToolProvider();

  @override
  void initState() {
    super.initState();
    _toolsFuture = _toolProvider.getTools();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('可用工具'),
      ),
      body: FutureBuilder<List<Tool>>(
        future: _toolsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('載入失敗: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('沒有可用的工具'),
            );
          }

          return ToolList(tools: snapshot.data!);
        },
      ),
    );
  }
}
