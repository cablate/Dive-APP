import 'package:flutter/material.dart';
import '../../data/models/tool_config.dart';
import '../../data/providers/tool_provider.dart';
import '../widgets/tools/tool_config_editor.dart';

class ToolConfigScreen extends StatefulWidget {
  const ToolConfigScreen({Key? key}) : super(key: key);

  @override
  State<ToolConfigScreen> createState() => _ToolConfigScreenState();
}

class _ToolConfigScreenState extends State<ToolConfigScreen> {
  final _toolProvider = ToolProvider();
  late Future<List<ToolConfig>> _configsFuture;

  @override
  void initState() {
    super.initState();
    _configsFuture = _toolProvider.getToolConfigs();
  }

  Future<void> _handleSave(String? toolName, ToolConfig config) async {
    try {
      await _toolProvider.updateToolConfig(
        toolName ?? config.name,
        config,
      );
      setState(() {
        _configsFuture = _toolProvider.getToolConfigs();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('儲存成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete(String toolName) async {
    try {
      await _toolProvider.deleteToolConfig(toolName);
      setState(() {
        _configsFuture = _toolProvider.getToolConfigs();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('刪除成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刪除失敗: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工具配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: ToolConfigEditor(
                    onSave: (config) {
                      Navigator.pop(context);
                      _handleSave(null, config);
                    },
                  ),
                ),
              );
            },
            tooltip: '新增工具',
          ),
        ],
      ),
      body: FutureBuilder<List<ToolConfig>>(
        future: _configsFuture,
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
              child: Text('沒有工具配置'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final config = snapshot.data![index];
              return ListTile(
                title: Text(config.name),
                subtitle: Text(config.command),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: config.enabled,
                      onChanged: (value) {
                        _handleSave(
                          config.name,
                          config.copyWith(enabled: value),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: ToolConfigEditor(
                              initialConfig: config,
                              onSave: (newConfig) {
                                Navigator.pop(context);
                                _handleSave(config.name, newConfig);
                              },
                              onDelete: () {
                                Navigator.pop(context);
                                _handleDelete(config.name);
                              },
                            ),
                          ),
                        );
                      },
                      tooltip: '編輯',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
} 