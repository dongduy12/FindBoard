import '../entities/code_entity.dart';
import '../entities/user_entity.dart';
import '../entities/search_list_entity.dart';
abstract class CodeRepository {
  Future<List<CodeEntity>> getCodeList(); // Giữ lại cho tương thích
  Future<bool> checkCode(String serialNumber); // Giữ lại cho tương thích
  Future<List<SearchListEntity>> getSearchList();
  Future<bool> updateScannedStatus(int searchListId, String serialNumber, bool isFound);
  Future<UserEntity> login(String email, String password);
}