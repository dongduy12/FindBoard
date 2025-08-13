import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/code_entity.dart';
import '../models/code_model.dart';
import '../models/user_model.dart';

class RemoteDataSource {
  final ApiClient apiClient;

  RemoteDataSource({required this.apiClient});

  Future<List<SearchListModel>> getSearchList() async {
    try {
      final response = await apiClient.get('/getsearchList');
      print('API GetSearchList Response: $response');
      if (response['success'] != true || response['data'] == null) {
        throw ServerException(response['message'] ?? 'Không thể lấy danh sách mã');
      }
      return (response['data'] as List)
          .map((json) => SearchListModel.fromJson(json))
          .toList();
    } catch (e) {
      print('API GetSearchList Error: $e');
      throw ServerException('Lỗi lấy danh sách mã: $e');
    }
  }

  Future<bool> updateScannedStatus(int searchListId, String serialNumber, bool isFound) async {
    try {
      final response = await apiClient.post('/UpdateScannedStatus', {
        'searchListId': searchListId,
        'serialNumber': serialNumber,
        'isFound': isFound,
      });
      print('API UpdateScannedStatus Request: {searchListId: $searchListId, serialNumber: $serialNumber, isFound: $isFound}');
      print('API UpdateScannedStatus Response: $response');
      if (response['success'] != true) {
        final errorMessage = response['message'] ?? 'Không thể cập nhật trạng thái';
        print('API UpdateScannedStatus Failed: $errorMessage');
        throw ServerException(errorMessage);
      }
      return true;
    } catch (e) {
      print('API UpdateScannedStatus Exception: $e');
      print('Stack trace: ${StackTrace.current}');
      throw ServerException('Lỗi cập nhật trạng thái: $e');
    }
  }


  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.post('/login', {
        'email': email,
        'password': password,
      });
      print('API Login Response: $response');
      if (response['success'] != true || response['user'] == null) {
        throw ValidationException('Email hoặc mật khẩu không đúng');
      }
      return UserModel.fromJson(response['user']);
    } catch (e) {
      print('API Login Error: $e');
      if (e is ValidationException) {
        throw e;
      }
      throw ServerException('Lỗi đăng nhập: $e');
    }
  }




}


