class LocalSearchListDb {
  final String id;
  final String listName;
  final String createdAt;
  final String createdBy;

  LocalSearchListDb({
    required this.id,
    required this.listName,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'listId': id,
      'listName': listName,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }

  factory LocalSearchListDb.fromMap(Map<String, dynamic> map) {
    return LocalSearchListDb(
      id: map['listId'] ?? '',
      listName: map['listName'] ?? '',
      createdAt: map['createdAt'] ?? '',
      createdBy: map['createdBy'] ?? '',
    );
  }
}
