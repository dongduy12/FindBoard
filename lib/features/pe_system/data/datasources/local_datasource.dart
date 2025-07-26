import '../../domain/entities/code_entity.dart';
import '../../domain/entities/search_list_entity.dart';
import '../models/local_code_item_db.dart';
import '../models/local_search_list_db.dart';
import 'database_helper.dart';

class LocalDataSource {
  final DatabaseHelper databaseHelper;

  LocalDataSource({required this.databaseHelper});

  Future<void> saveCodes(List<CodeEntity> codes, String listId) async {
    final localCodes = codes
        .map((code) => LocalCodeItemDb(
      serialNumber: code.serialNumber,
      listId: listId,
      isFound: code.isFound,
    ))
        .toList();
    await databaseHelper.insertCodes(localCodes, listId);
  }

  Future<void> saveSearchLists(List<SearchListEntity> lists) async {
    final localLists = lists
        .map((e) => LocalSearchListDb(
              id: e.id,
              listName: e.listName,
              createdAt: e.createdAt.toIso8601String(),
              createdBy: e.createdBy,
            ))
        .toList();
    await databaseHelper.insertSearchLists(localLists);
    for (var list in lists) {
      await saveCodes(list.items, list.id);
    }
  }

  Future<List<SearchListEntity>> getSearchLists() async {
    final localLists = await databaseHelper.getSearchLists();
    List<SearchListEntity> result = [];
    for (var list in localLists) {
      final codes = await getCodesByListId(list.id);
      result.add(SearchListEntity(
        id: list.id,
        listName: list.listName,
        createdAt: DateTime.tryParse(list.createdAt) ?? DateTime.now(),
        createdBy: list.createdBy,
        items: codes,
      ));
    }
    return result;
  }

  Future<List<CodeEntity>> getCodesByListId(String listId) async {
    final localCodes = await databaseHelper.getCodesByListId(listId);
    return localCodes
        .map((local) => CodeEntity(
      id: '',
      serialNumber: local.serialNumber,
      modelName: '',
      shelfCode: '',
      isFound: local.isFound,
    ))
        .toList();
  }

  Future<CodeEntity?> findCode(String serialNumber, String listId) async {
    final localCode = await databaseHelper.findCode(serialNumber, listId);
    if (localCode == null) return null;
    return CodeEntity(
      id: '',
      serialNumber: localCode.serialNumber,
      modelName: '',
      shelfCode: '',
      isFound: localCode.isFound,
    );
  }

  Future<void> updateFoundStatus(String serialNumber, String listId, bool isFound) async {
    await databaseHelper.updateFoundStatus(serialNumber, listId, isFound);
  }

  Future<List<CodeEntity>> getFoundCodesByListId(String listId) async {
    final localCodes = await databaseHelper.getFoundCodesByListId(listId);
    return localCodes
        .map((local) => CodeEntity(
      id: '',
      serialNumber: local.serialNumber,
      modelName: '',
      shelfCode: '',
      isFound: true,
    ))
        .toList();
  }

  Future<void> clearAllData() async {
    await databaseHelper.clearAllData();
  }
}