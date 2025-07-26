// lib/features/pe_system/data/models/local_code_item_db.dart

class LocalCodeItemDb {
  final String serialNumber;
  final String listId;
  bool isFound;

  LocalCodeItemDb({
    required this.serialNumber,
    required this.listId,
    this.isFound = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'serialNumber': serialNumber,
      'listId': listId,
      'isFound': isFound ? 1 : 0,
    };
  }

  factory LocalCodeItemDb.fromMap(Map<String, dynamic> map) {
    return LocalCodeItemDb(
      serialNumber: map['serialNumber'] ?? '',
      listId: map['listId'] ?? '',
      isFound: map['isFound'] == 1,
    );
  }

  @override
  String toString() {
    return 'LocalCodeItemDb(serialNumber: $serialNumber, listId: $listId, isFound: $isFound)';
  }
}