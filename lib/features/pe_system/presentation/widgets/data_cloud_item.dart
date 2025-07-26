class DataCloudItem {
  final String name;
  final String path;
  final String type;

  DataCloudItem({
    required this.name,
    required this.path,
    required this.type,
  });

  factory DataCloudItem.fromJson(Map<String, dynamic> json) {
    return DataCloudItem(
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
    );
  }
}

class DataCloudResponse {
  final String currentPath;
  final List<DataCloudItem> items;

  DataCloudResponse({
    required this.currentPath,
    required this.items,
  });

  factory DataCloudResponse.fromJson(Map<String, dynamic> json) {
    return DataCloudResponse(
      currentPath: json['currentPath'] as String,
      items: (json['items'] as List)
          .map((item) => DataCloudItem.fromJson(item))
          .toList(),
    );
  }
}