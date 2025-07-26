import 'package:mobile_app/features/pe_system/data/datasources/local_datasource.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/code_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/search_list_entity.dart';
import '../../domain/repositories/code_repository.dart';
import '../datasources/remote_datasource.dart';

class CodeRepositoryImpl implements CodeRepository {
  final RemoteDataSource remoteDataSource;

  CodeRepositoryImpl({
    required this.remoteDataSource
  });

  @override
  Future<List<SearchListEntity>> getSearchList() async {
    try {
      final searchLists = await remoteDataSource.getSearchList();
      return searchLists
          .map((model) => SearchListEntity(
        id: model.id,
        listName: model.listName,
        createdAt: model.createdAt,
        createdBy: model.createdBy,
        items: model.items
            .map((item) => CodeEntity(
          id: item.id,
          serialNumber: item.serialNumber,
          modelName: item.modelName,
          shelfCode: item.shelfCode,
          columnNumber: item.columnNumber,
          levelNumber: item.levelNumber,
          trayNumber: item.trayNumber,
          positionInTray: item.positionInTray,
          isFound: item.isFound,
        ))
            .toList(),
      ))
          .toList();
    } catch (e) {
      throw ServerException('Lỗi lấy danh sách mã: $e');
    }
  }

  @override
  Future<bool> updateScannedStatus(int searchListId, String serialNumber, bool isFound) async {
    try {
      return await remoteDataSource.updateScannedStatus(searchListId, serialNumber,isFound);
    } catch (e) {
      throw ServerException('Lỗi cập nhật trạng thái: $e');
    }
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return UserEntity(id: userModel.id, email: userModel.email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CodeEntity>> getCodeList() {
    throw UnimplementedError(); // Không còn cần thiết vì dùng getSearchList
  }

  @override
  Future<bool> checkCode(String serialNumber) {
    throw UnimplementedError(); // Không còn cần thiết vì dùng updateScannedStatus
  }

}