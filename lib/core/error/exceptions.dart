// xử lý lôĩ (API, mạng, ...)
//ServerException: Xử lý lỗi từ server (như lỗi mạng, API).
class ServerException implements Exception{
  final String message;
  ServerException(this.message);
}

//ValidationException: Xử lý lỗi xác thực (như email/password không hợp lệ).
class ValidationException implements Exception{
  final String message;
  ValidationException(this.message);
}