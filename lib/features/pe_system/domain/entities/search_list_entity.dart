import 'code_entity.dart';

class SearchListEntity {
  final String id;
  final String listName;
  final DateTime createdAt;
  final String createdBy;
  final List<CodeEntity> items;

  SearchListEntity({
    required this.id,
    required this.listName,
    required this.createdAt,
    required this.createdBy,
    required this.items,
  });
}