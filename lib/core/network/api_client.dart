//Xử lý gọi API,...
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../error/exceptions.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl})
      : _client = IOClient(
          HttpClient()
            ..badCertificateCallback =
                (X509Certificate cert, String host, int port) =>
                    host == 'pe-vnmbd-nvidia-cns.myfiinet.com',
        );

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl$endpoint'));
      return _handleResponse(response);
    } catch (e) {
      throw ServerException('Loi lay du lieu: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
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
