import '../entities/code_entity.dart';
import '../entities/user_entity.dart';
import '../entities/search_list_entity.dart';
import '../repositories/code_repository.dart';

class ManageCodesUseCase {
  final CodeRepository repository;

  ManageCodesUseCase({required this.repository});

  Future<List<CodeEntity>> getCodeList() async {
    return await repository.getCodeList();
  }

  Future<bool> checkCode(String serialNumber) async {
    return await repository.checkCode(serialNumber);
  }

  Future<List<SearchListEntity>> getSearchList() async {
    return await repository.getSearchList();
  }

  Future<bool> updateScannedStatus(int searchListId, String serialNumber, bool isFound) async {
    return await repository.updateScannedStatus(searchListId, serialNumber, isFound);
  }

  Future<UserEntity> login(String email, String password) async {
    return await repository.login(email, password);
  }

}