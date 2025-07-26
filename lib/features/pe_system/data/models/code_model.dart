class CodeModel {
  final String id;
  final String serialNumber;
  final String modelName;
  final String shelfCode;
  final int columnNumber;
  final int levelNumber;
  final int trayNumber;
  final int positionInTray;
  final bool isFound;

  CodeModel({
    required this.id,
    required this.serialNumber,
    required this.modelName,
    required this.shelfCode,
    required this.columnNumber,
    required this.levelNumber,
    required this.trayNumber,
    required this.positionInTray,
    required this.isFound,
  });

  factory CodeModel.fromJson(Map<String, dynamic> json) {
    return CodeModel(
      id: json['id']?.toString() ?? '',
      serialNumber: json['serialNumber'] ?? '',
      modelName: json['modelName'] ?? '',
      shelfCode: json['shelfCode'] ?? '',
      columnNumber: json['columnNumber'] ?? 0,
      levelNumber: json['levelNumber'] ?? 0,
      trayNumber: json['trayNumber'] ?? 0,
      positionInTray: json['positionInTray'] ?? 0,
      isFound: json['isFound'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serialNumber': serialNumber,
      'modelName': modelName,
      'shelfCode': shelfCode,
      'columnNumber': columnNumber,
      'levelNumber': levelNumber,
      'trayNumber': trayNumber,
      'positionInTray': positionInTray,
      'isFound': isFound,
    };
  }
}

class SearchListModel {
  final String id;
  final String listName;
  final DateTime createdAt;
  final String createdBy;
  final List<CodeModel> items;

  SearchListModel({
    required this.id,
    required this.listName,
    required this.createdAt,
    required this.createdBy,
    required this.items,
  });

  factory SearchListModel.fromJson(Map<String, dynamic> json) {
    print('Parsing SearchListModel: $json'); // Thêm log để kiểm tra JSON
    return SearchListModel(
      id: json['id']?.toString() ?? '', // Chú ý: API trả về "id" (chữ thường)
      listName: json['listName'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CodeModel.fromJson(item))
          .toList() ??
          [],
    );
  }
}