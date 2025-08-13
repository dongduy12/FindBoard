import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/local_datasource.dart';
import '../../domain/entities/code_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/search_list_entity.dart';
import '../../domain/usecases/manage_codes_usecase.dart';

class CodeProvider with ChangeNotifier {
  final ManageCodesUseCase useCase;
  final LocalDataSource localDataSource;
  final Connectivity connectivity;

  List<SearchListEntity> _searchLists = [];
  List<CodeEntity> _codeList = [];
  List<String> _foundCodes = [];
  List<String> _orderedFoundCodes = [];
  List<String> _recentlyScannedCodes = [];
  bool _isLoading = false;
  String? _error;

  UserEntity? _user;
  bool _isLoggingIn = false;
  String? _loginError;

  int _selectedIndex = 0;
  int? _selectedSearchListIndex;

  String? _scannedSerialNumber;
  String? _retestResult;
  File? _retestImage;
  bool _isSubmittingRetest = false;
  String? _retestError;
  String _employeeId = 'debug';
  String? _notes;
  String _handOverStatus = 'WAITING_HAND_OVER';

  List<SearchListEntity> get searchLists => _searchLists;
  List<CodeEntity> get codeList => _codeList;
  List<String> get foundCodes => _foundCodes;
  List<String> get recentlyScannedCodes => _recentlyScannedCodes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserEntity? get user => _user;
  bool get isLoggingIn => _isLoggingIn;
  String? get loginError => _loginError;

  int get selectedIndex => _selectedIndex;
  int? get selectedSearchListIndex => _selectedSearchListIndex;

  int get foundCount => _foundCodes.length;
  int get totalCount => _codeList.length;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String? get scannedSerialNumber => _scannedSerialNumber;
  String? get retestResult => _retestResult;
  File? get retestImage => _retestImage;
  bool get isSubmittingRetest => _isSubmittingRetest;
  String? get retestError => _retestError;
  String get employeeId => _employeeId;
  String? get notes => _notes;
  String get handOverStatus => _handOverStatus;

  CodeProvider({
    required this.useCase,
    required this.localDataSource,
    required this.connectivity,
  });

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _loadLoginStatus();
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<bool> _isConnected() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoggingIn = true;
      _loginError = null;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1));
      if (email == 'test@example.com' && password == 'password') {
        _user = UserEntity.fromJson({'id': 1, 'email': email});
        _isLoggedIn = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await fetchSearchList();
        _isLoggingIn = false;
        notifyListeners();
        return true;
      } else {
        _loginError = 'Email hoặc mật khẩu không đúng';
        _isLoggingIn = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _loginError = 'Lỗi đăng nhập: $e';
      _isLoggingIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _selectedIndex = 0;
    _searchLists = [];
    _codeList = [];
    _foundCodes = [];
    _orderedFoundCodes = [];
    _recentlyScannedCodes = [];
    _selectedSearchListIndex = null;
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }

  Future<void> fetchSearchList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    bool online = await _isConnected();
    if (online) {
      try {
        _searchLists = await useCase.getSearchList();
        await localDataSource.saveSearchLists(_searchLists);
      } catch (e) {
        _error = e.toString();
        print('Fetch error: $_error');
      }
    }
    if (!online || _searchLists.isEmpty) {
      try {
        _searchLists = await localDataSource.getSearchLists();
      } catch (e) {
        _error ??= e.toString();
      }
    }
    _selectedSearchListIndex = null;
    _recentlyScannedCodes = [];
    _updateCodeList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateScannedStatus(int searchListId, String serialNumber, bool isScanned) async {
    try {
      if (_foundCodes.contains(serialNumber)) {
        _orderedFoundCodes.remove(serialNumber);
        _recentlyScannedCodes.remove(serialNumber);
        _orderedFoundCodes.insert(0, serialNumber);
        _recentlyScannedCodes.insert(0, serialNumber);
      } else {
        bool online = await _isConnected();
        if (online) {
          await useCase.updateScannedStatus(searchListId, serialNumber, isScanned);
        }
        await localDataSource.updateFoundStatus(serialNumber, searchListId.toString(), isScanned);
        _foundCodes.add(serialNumber);
        _orderedFoundCodes.insert(0, serialNumber);
        _recentlyScannedCodes.insert(0, serialNumber);
      }

      final existingCode = _codeList.firstWhere(
            (item) => item.serialNumber == serialNumber,
        orElse: () => CodeEntity(
          id: '',
          serialNumber: serialNumber,
          modelName: '',
          shelfCode: '',
          isFound: true,
        ),
      );
      _codeList = [
        existingCode.copyWith(isFound: true, foundOrder: 1),
        ..._codeList
            .where((item) => item.serialNumber != serialNumber)
            .map((item) => item.isFound && _orderedFoundCodes.contains(item.serialNumber)
                ? item.copyWith(foundOrder: _orderedFoundCodes.indexOf(item.serialNumber) + 1)
                : item),
      ];
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> syncFoundCodes() async {
    if (!await _isConnected()) return;
    try {
      final lists = await localDataSource.getSearchLists();
      for (var list in lists) {
        final found = await localDataSource.getFoundCodesByListId(list.id);
        for (var code in found) {
          try {
            await useCase.updateScannedStatus(int.parse(list.id), code.serialNumber, true);
          } catch (_) {}
        }
      }
    } catch (e) {
      print('syncFoundCodes error: $e');
    }
  }

  Future<bool> handleScanCode(String code, int? searchListId) async {
    if (searchListId == null) {
      _error = 'Vui lòng chọn một danh sách trước khi quét!';
      notifyListeners();
      return false;
    }
    code = code.trim();

    // Cập nhật trạng thái isFound
    await updateScannedStatus(searchListId, code, true);
    return foundCodes.contains(code);
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setSelectedSearchListIndex(int index) {
    _selectedSearchListIndex = index;
    _recentlyScannedCodes = [];
    print('Selected search list index: $index');
    _updateCodeList();
  }

  void _updateCodeList() {
    if (_selectedSearchListIndex != null && _searchLists.isNotEmpty) {
      _codeList = _searchLists[_selectedSearchListIndex!].items;
      _foundCodes = _codeList
          .where((item) => item.isFound)
          .map((item) => item.serialNumber)
          .toList();
      print('Updated _codeList: $_codeList');
      print('Updated _foundCodes: $_foundCodes');

      _orderedFoundCodes = _foundCodes.toList();
      _codeList = _codeList.map((item) {
        if (_orderedFoundCodes.contains(item.serialNumber)) {
          return item.copyWith(foundOrder: _orderedFoundCodes.indexOf(item.serialNumber) + 1);
        }
        return item;
      }).toList();



    } else {
      _codeList = [];
      _foundCodes = [];
      _orderedFoundCodes = [];
      _recentlyScannedCodes = [];
      print('Cleared _codeList: $_codeList');
    }
    notifyListeners();
  }

  // Thêm phương thức updateScannedSerialNumber

  //===========CHUC NANG RETEST=============

  void updateScannedSerialNumber(String serialNumber) {
    _scannedSerialNumber = serialNumber;
    _retestResult = null;
    _retestImage = null;
    _retestError = null;
    notifyListeners();
  }

  // Chọn trạng thái Pass/Fail
  void setRetestResult(String? result) {
    _retestResult = result;
    notifyListeners();
  }

  // Nhập ghi chú
  void setNotes(String? notes) {
    _notes = notes;
    notifyListeners();
  }

  // Chụp ảnh
  Future<void> pickImage() async {
    try {
      await _requestCameraPermission();
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        _retestImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _retestError = 'Lỗi khi chụp ảnh: $e';
      notifyListeners();
    }
  }

  // Gửi kết quả Retest lên API
  Future<void> submitRetest() async {
    if (_scannedSerialNumber == null || _retestResult == null || _retestImage == null) {
      print('Validation failed: serialNumber=$_scannedSerialNumber, result=$_retestResult, image=$_retestImage');
      _retestError = 'Vui lòng điền đầy đủ thông tin (mã, trạng thái, và ảnh).';
      notifyListeners();
      return;
    }
    // // Kiểm tra status
    // if (_retestResult != 'Pass' && _retestResult != 'Fail') {
    //   print('Invalid status: $_retestResult');
    //   _retestError = 'Trạng thái chỉ được là "Pass" hoặc "Fail".';
    //   notifyListeners();
    //   return;
    // }

    // Kiểm tra file ảnh
    if (!await _retestImage!.exists()) {
      print('Image file does not exist: ${_retestImage!.path}');
      _retestError = 'File ảnh không tồn tại.';
      notifyListeners();
      return;
    }

    _isSubmittingRetest = true;
    _retestError = null;
    notifyListeners();
    print('Starting submission process...');

    try {
      print('Sending: serialNumber=$_scannedSerialNumber, status=$_retestResult, employeeId=$_employeeId, notes=$_notes, handOverStatus=$_handOverStatus, imagePath=${_retestImage!.path}');
      final client = _createIoClient();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://pe-vnmbd-cns.myfiinet.com:9090/api/RetestResult/submit-with-img'),
      );

      request.fields['serialNumber'] = _scannedSerialNumber!;
      request.fields['status'] = _retestResult!;
      request.fields['employeeId'] = _employeeId;
      request.fields['notes'] = _notes ?? '';
      request.fields['handOverStatus'] = _handOverStatus;
      request.files.add(await http.MultipartFile.fromPath('image', _retestImage!.path));

      var response = await client.send(request).timeout(const Duration(seconds: 60));

      print('API response status: ${response.statusCode}');
      var responseBody = await http.Response.fromStream(response);
      print('API response body: ${responseBody.body}');

      if (response.statusCode == 200) {
        print('Submission successful');
        _scannedSerialNumber = null;
        _retestResult = null;
        _retestImage = null;
        _notes = null;
        _retestError = null;
      } else {
        print('Submission failed with status: ${response.statusCode}');
        _retestError = 'Lỗi khi gửi kết quả: ${response.statusCode} - ${responseBody.body}';
      }
    } catch (e) {
      print('Error in submitRetest: $e');
      _retestError = 'Lỗi khi gửi kết quả: $e';
    }

    _isSubmittingRetest = false;
    notifyListeners();
    print('submitRetest completed');
  }

  // Lấy kết quả Retest từ API
  Future<Map<String, dynamic>> fetchRetestResult(String serialNumber) async {
    try {
      final client = _createIoClient();
      final response = await client.get(
        Uri.parse('https://pe-vnmbd-nvidia-cns.myfiinet.com:9090/api/RetestResult/get-result/$serialNumber'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {'success': false, 'error': 'Failed to fetch result: ${response.statusCode} - ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Thêm phương thức requestCameraPermission (public)
  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception('Camera permission denied');
    }
  }

  // Phương thức private để gọi trong các hàm khác
  Future<void> _requestCameraPermission() async {
    await requestCameraPermission();
  }
  http.Client _createIoClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
      host == 'pe-vnmbd-cns.myfiinet.com';
    return IOClient(ioClient);
  }
}