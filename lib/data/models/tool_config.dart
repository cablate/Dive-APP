class ToolConfig {
  final String name;
  final String command;
  final List<String> args;
  final Map<String, String> env;
  final bool enabled;

  ToolConfig({
    required this.name,
    required this.command,
    required this.args,
    required this.env,
    this.enabled = true,
  });

  factory ToolConfig.fromJson(MapEntry<String, dynamic> entry) {
    final name = entry.key;
    final data = entry.value as Map<String, dynamic>;
    
    return ToolConfig(
      name: name,
      command: data['command'] ?? '',
      args: List<String>.from(data['args'] ?? []),
      env: Map<String, String>.from(data['env'] ?? {}),
      enabled: data['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'args': args,
      'env': env,
      'enabled': enabled,
    };
  }

  ToolConfig copyWith({
    String? name,
    String? command,
    List<String>? args,
    Map<String, String>? env,
    bool? enabled,
  }) {
    return ToolConfig(
      name: name ?? this.name,
      command: command ?? this.command,
      args: args ?? this.args,
      env: env ?? this.env,
      enabled: enabled ?? this.enabled,
    );
  }
} 