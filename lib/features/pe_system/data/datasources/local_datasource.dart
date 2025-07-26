import '../../domain/entities/code_entity.dart';
import '../models/local_code_item_db.dart';
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