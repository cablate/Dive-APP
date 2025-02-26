import 'package:flutter/material.dart';

import '../../../data/models/tool_config.dart';

class ToolConfigEditor extends StatefulWidget {
  final ToolConfig? initialConfig;
  final Function(ToolConfig) onSave;
  final VoidCallback? onDelete;

  const ToolConfigEditor({
    Key? key,
    this.initialConfig,
    required this.onSave,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ToolConfigEditor> createState() => _ToolConfigEditorState();
}

class _ToolConfigEditorState extends State<ToolConfigEditor> {
  late TextEditingController _nameController;
  late TextEditingController _commandController;
  late List<String> _args;
  late Map<String, String> _env;
  late List<TextEditingController> _argControllers;
  late Map<String, (TextEditingController, TextEditingController)>
      _envControllers;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialConfig?.name ?? '');
    _commandController =
        TextEditingController(text: widget.initialConfig?.command ?? '');
    _args = List.from(widget.initialConfig?.args ?? []);
    _argControllers =
        _args.map((arg) => TextEditingController(text: arg)).toList();

    _env = Map.from(widget.initialConfig?.env ?? {});
    _envControllers = Map.fromEntries(
      _env.entries.map(
        (e) => MapEntry(
          e.key,
          (
            TextEditingController(text: e.key),
            TextEditingController(text: e.value)
          ),
        ),
      ),
    );
    _enabled = widget.initialConfig?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commandController.dispose();
    for (var controller in _argControllers) {
      controller.dispose();
    }
    for (var controllers in _envControllers.values) {
      controllers.$1.dispose();
      controllers.$2.dispose();
    }
    super.dispose();
  }

  void _addArg() {
    setState(() {
      _args.add('');
      _argControllers.add(TextEditingController());
    });
  }

  void _updateArg(int index, String value) {
    setState(() {
      _args[index] = value;
    });
  }

  void _removeArg(int index) {
    setState(() {
      _args.removeAt(index);
      _argControllers[index].dispose();
      _argControllers.removeAt(index);
    });
  }

  void _addEnvironment() {
    setState(() {
      const newKey = '';
      _env[newKey] = '';
      _envControllers[newKey] = (
        TextEditingController(),
        TextEditingController(),
      );
    });
  }

  void _updateEnvironment(String oldKey, String newKey, String value) {
    setState(() {
      if (oldKey != newKey) {
        _env.remove(oldKey);
        final controllers = _envControllers[oldKey];
        if (controllers != null) {
          _envControllers.remove(oldKey);
          _envControllers[newKey] = controllers;
        }
      }
      _env[newKey] = value;
    });
  }

  void _removeEnvironment(String key) {
    setState(() {
      _env.remove(key);
      final controllers = _envControllers[key];
      if (controllers != null) {
        controllers.$1.dispose();
        controllers.$2.dispose();
        _envControllers.remove(key);
      }
    });
  }

  void _handleSave() {
    final config = ToolConfig(
      name: _nameController.text,
      command: _commandController.text,
      args: _args,
      env: _env,
      enabled: _enabled,
    );
    widget.onSave(config);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '工具名稱',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commandController,
            decoration: const InputDecoration(
              labelText: '命令',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('啟用'),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          const SizedBox(height: 16),
          _buildArgsList(),
          const SizedBox(height: 16),
          _buildSection(
            title: '環境變數',
            items: _env,
            onAdd: _addEnvironment,
            onUpdate: _updateEnvironment,
            onRemove: _removeEnvironment,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.onDelete != null)
                TextButton(
                  onPressed: widget.onDelete,
                  child: const Text('刪除'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _handleSave,
                child: const Text('儲存'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArgsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '參數',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addArg,
              tooltip: '新增參數',
            ),
          ],
        ),
        ..._args.asMap().entries.map((entry) {
          final index = entry.key;
          final arg = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '參數值',
                      border: OutlineInputBorder(),
                    ),
                    controller: _argControllers[index],
                    onChanged: (value) => _updateArg(index, value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeArg(index),
                  tooltip: '刪除',
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Map<String, String> items,
    required VoidCallback onAdd,
    required Function(String, String, String) onUpdate,
    required Function(String) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAdd,
              tooltip: '新增$title',
            ),
          ],
        ),
        ...items.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '${title}名稱',
                      border: const OutlineInputBorder(),
                    ),
                    controller: _envControllers[entry.key]?.$1,
                    onChanged: (value) =>
                        _updateEnvironment(entry.key, value, entry.value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '${title}值',
                      border: const OutlineInputBorder(),
                    ),
                    controller: _envControllers[entry.key]?.$2,
                    onChanged: (value) =>
                        _updateEnvironment(entry.key, entry.key, value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onRemove(entry.key),
                  tooltip: '刪除',
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
