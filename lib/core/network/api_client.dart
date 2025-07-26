//Xử lý gọi API,...
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../error/exceptions.dart';
class ApiClient{
  final String baseUrl;
  ApiClient({required this.baseUrl});
  Future<dynamic> get(String endpoint) async{
    try{
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      return _handleResponse(response);
    }catch(e) {
      throw ServerException('Loi lay du lieu: $e');
    }
  }
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ServerException('Lỗi gửi dữ liệu: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ServerException('Lỗi server: ${response.statusCode}');
    }
  }
}