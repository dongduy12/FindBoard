class CodeEntity {
  final String id;
  final String serialNumber;
  final String modelName;
  final String shelfCode;
  final int columnNumber;
  final int levelNumber;
  final int trayNumber;
  final int positionInTray;
  final bool isFound;
  final int? foundOrder;

  CodeEntity({
    required this.id,
    required this.serialNumber,
    required this.modelName,
    required this.shelfCode,
    this.columnNumber = 0, // Giá trị mặc định
    this.levelNumber = 0,
    this.trayNumber = 0,
    this.positionInTray = 0,
    required this.isFound,
    this.foundOrder,
  });

  CodeEntity copyWith({
    String? id,
    String? serialNumber,
    String? modelName,
    String? shelfCode,
    int? columnNumber,
    int? levelNumber,
    int? trayNumber,
    int? positionInTray,
    bool? isFound,
    int? foundOrder,
}){
    return CodeEntity(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      modelName: modelName ?? this.modelName,
      shelfCode: shelfCode ?? this.shelfCode,
      columnNumber: columnNumber ?? this.columnNumber,
      levelNumber: levelNumber ?? this.levelNumber,
      trayNumber: trayNumber ?? this.trayNumber,
      positionInTray: positionInTray ?? this.positionInTray,
      isFound: isFound ?? this.isFound,
      foundOrder: foundOrder ?? this.foundOrder,
    );
  }
  @override
  String toString() {
    return 'CodeEntity(id: $id, serialNumber: $serialNumber, isFound: $isFound, foundOrder: $foundOrder)';
  }
}