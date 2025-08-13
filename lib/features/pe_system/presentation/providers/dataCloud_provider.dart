import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../widgets/data_cloud_item.dart';

class DatacloudProvider with ChangeNotifier {
  DataCloudResponse? _dataCloudResponse;
  String? _dataCloudError;
  bool _isLoadingDataCloud = false;
  List<String> _pathHistory = ['D:\\DataCloud']; // Quản lý lịch sử đường dẫn

  DataCloudResponse? get dataCloudResponse => _dataCloudResponse;
  String? get dataCloudError => _dataCloudError;
  bool get isLoadingDataCloud => _isLoadingDataCloud;
  List<String> get pathHistory => _pathHistory;

  Future<void> fetchDataCloud({String? path}) async {
    _isLoadingDataCloud = true;
    _dataCloudError = null;
    notifyListeners();

    try {
      final normalizedPath = normalizePath(path ?? _pathHistory.last);
      final response = await http
          .get(Uri.parse('http://pe-vnmbd-nvidia-cns.myfiinet.com:8000/api/data/get-data?path=${Uri.encodeComponent(normalizedPath)}'))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        _dataCloudResponse = DataCloudResponse.fromJson(jsonDecode(response.body));
        if (!_pathHistory.contains(normalizedPath) && normalizedPath != _pathHistory[0]) {
          _pathHistory.add(normalizedPath);
        }
      } else {
        _dataCloudError = 'Failed to load DataCloud: ${response.statusCode}';
      }
    } catch (e) {
      _dataCloudError = 'Error fetching DataCloud: $e';
    }

    _isLoadingDataCloud = false;
    notifyListeners();
  }

  Future<void> searchDataCloud(String keyword) async {
    _isLoadingDataCloud = true;
    _dataCloudError = null;
    notifyListeners();

    try {
      final currentPath = normalizePath(_pathHistory.last);
      final response = await http
          .get(Uri.parse('http://pe-vnmbd-nvidia-cns.myfiinet.com:8000/api/data/search?keyword=${Uri.encodeComponent(keyword)}&path=${Uri.encodeComponent(currentPath)}'))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        _dataCloudResponse = DataCloudResponse.fromJson(jsonDecode(response.body));
      } else {
        _dataCloudError = 'Failed to search DataCloud: ${response.statusCode}';
      }
    } catch (e) {
      _dataCloudError = 'Error searching DataCloud: $e';
    }

    _isLoadingDataCloud = false;
    notifyListeners();
  }

  Future<void> deleteItem(String path, String type) async {
    try {
      final response = await http.post(
        Uri.parse('http://pe-vnmbd-nvidia-cns.myfiinet.com:8000/api/data/delete-items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([{'path': normalizePath(path), 'type': type}]),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        await fetchDataCloud(path: _pathHistory[_pathHistory.length - 2]); // Tải lại thư mục cha
      } else {
        throw Exception('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      _dataCloudError = 'Error deleting item: $e';
      notifyListeners();
    }
  }

  Future<void> createFolder(String folderName) async {
    try {
      final currentPath = normalizePath(_pathHistory.last);
      final response = await http.post(
        Uri.parse('http://pe-vnmbd-nvidia-cns.myfiinet.com:8000/api/data/create-folder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'path': currentPath, 'folderName': folderName}),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        await fetchDataCloud();
      } else {
        throw Exception('Failed to create folder: ${response.statusCode}');
      }
    } catch (e) {
      _dataCloudError = 'Error creating folder: $e';
      notifyListeners();
    }
  }

  Future<void> uploadFiles(List<File> files, {bool isFolder = false}) async {
    _isLoadingDataCloud = true;
    _dataCloudError = null;
    notifyListeners();

    try {
      const maxSize = 100 * 1024 * 1024; // 100MB
      for (var file in files) {
        if (await file.length() > maxSize) {
          _dataCloudError = 'File ${file.path.split('/').last} exceeds 100MB.';
          notifyListeners();
          return;
        }
      }

      final currentPath = normalizePath(_pathHistory.last);
      var request = http.MultipartRequest(
        isFolder ? 'POST' : 'POST',
        Uri.parse('http://pe-vnmbd-nvidia-cns.myfiinet.com:8000/api/data/${isFolder ? 'upload-folder' : 'upload-file'}'),
      );
      request.fields['path'] = currentPath;

      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath(
          'files',
          file.path,
          contentType: MediaType('application', 'octet-stream'),
        ));
      }

      final response = await request.send().timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        await fetchDataCloud();
      } else {
        throw Exception('Failed to upload: ${response.statusCode}');
      }
    } catch (e) {
      _dataCloudError = 'Error uploading files: $e';
      notifyListeners();
    }

    _isLoadingDataCloud = false;
    notifyListeners();
  }

  String normalizePath(String? path) {
    if (path == null) return 'D:\\DataCloud';
    return path
        .replaceAll(RegExp(r'\\+'), '\\')
        .replaceAll(RegExp(r'\\$'), '')
        .replaceAll(RegExp(r'^D:\\DataCloud\\DataCloud'), 'D:\\DataCloud');
  }
}