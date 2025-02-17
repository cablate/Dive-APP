class Tool {
  final String name;
  final String description;
  final List<ToolFunction> tools;
  final bool enabled;
  final String icon;

  Tool({
    required this.name,
    required this.description,
    required this.tools,
    required this.enabled,
    required this.icon,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tools: (json['tools'] as List<dynamic>)
          .map((tool) => ToolFunction.fromJson(tool))
          .toList(),
      enabled: json['enabled'] ?? false,
      icon: json['icon'] ?? '',
    );
  }
}

class ToolFunction {
  final String name;
  final String description;

  ToolFunction({
    required this.name,
    required this.description,
  });

  factory ToolFunction.fromJson(Map<String, dynamic> json) {
    return ToolFunction(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
} 