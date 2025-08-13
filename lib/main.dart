// lib/
// ├── core/
// │   ├── network/
// │   │   └── api_client.dart       # Xử lý gọi API chung
// │   ├── error/
// │   │   └── exceptions.dart       # Định nghĩa lỗi (API, mạng)
// │   └── constants/
// │       └── colors.dart           # Màu sắc, hằng số chung
// ├── features/
// │   └── pe_system/
// │       ├── data/
// │       │   ├── models/
// │       │   │   └── code_model.dart  # Mô hình dữ liệu từ API
// │       │   ├── repositories/
// │       │   │   └── code_repository_impl.dart  # Triển khai repository
// │       │   └── datasources/
// │       │       └── remote_datasource.dart    # Gọi API cụ thể
// │       ├── domain/
// │       │   ├── entities/
// │       │   │   └── code_entity.dart  # Mô hình dữ liệu thuần túy
// │       │   ├── repositories/
// │       │   │   └── code_repository.dart  # Interface cho repository
// │       │   └── usecases/
// │       │       └── manage_codes_usecase.dart  # Logic nghiệp vụ
// │       └── presentation/
// │           ├── providers/
// │           │   └── code_provider.dart    # Quản lý trạng thái
// │           ├── screens/
// │           │   └── pe_system_screen.dart  # Màn hình chính
// │           └── widgets/
// │               ├── code_item.dart        # Widget mã trong danh sách
// ├── main.dart                            # Điểm vào ứng dụng
// pubspec.yaml                            # Cấu hình dependencies

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/pe_system/presentation/providers/theme_provider.dart';
import 'features/pe_system/presentation/providers/code_provider.dart';
import 'features/pe_system/presentation/providers/dataCloud_provider.dart';
import 'features/pe_system/presentation/providers/language_provider.dart';
import 'features/pe_system/presentation/screens/sign_in_page.dart';
import 'features/pe_system/presentation/screens/navigation_rail_page.dart';
import 'features/pe_system/presentation/screens/pe_system_screen.dart';
import 'core/network/api_client.dart';
import 'features/pe_system/data/datasources/remote_datasource.dart';
import 'features/pe_system/data/datasources/local_datasource.dart';
import 'features/pe_system/data/datasources/database_helper.dart';
import 'features/pe_system/data/repositories/code_repository_impl.dart';
import 'features/pe_system/domain/usecases/manage_codes_usecase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final apiClient = ApiClient(baseUrl: 'https://pe-vnmbd-cns.myfiinet.com:9090/api/search');
  final remoteDataSource = RemoteDataSource(apiClient: apiClient);
  final localDataSource = LocalDataSource(databaseHelper: DatabaseHelper.instance);
  final repository = CodeRepositoryImpl(remoteDataSource: remoteDataSource);
  final useCase = ManageCodesUseCase(repository: repository);
  final codeProvider = CodeProvider(
    useCase: useCase,
    localDataSource: localDataSource,
    connectivity: Connectivity(),
  );
  final themeProvider = ThemeProvider();
  final dataCloudProvider = DatacloudProvider(); // Khởi tạo DataCloudProvider
  final languageProvider = LanguageProvider();

  // Khởi tạo async cho các provider
  await Future.wait([
    codeProvider.initialize(),
    themeProvider.initialize(),
    dataCloudProvider.fetchDataCloud(),
    languageProvider.initialize(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => codeProvider),
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => dataCloudProvider),
        ChangeNotifierProvider(create: (_) => languageProvider),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDarkMode = _getIsDarkMode(themeProvider, context);

    print('MyApp: Setting SystemUIOverlayStyle (didChangeDependencies), isDarkMode: $isDarkMode');
    _updateSystemUIOverlayStyle(isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final codeProvider = Provider.of<CodeProvider>(context, listen: false);
    bool isDarkMode = _getIsDarkMode(themeProvider, context);
    final appBarBackgroundColor = isDarkMode ? Colors.grey[900] : AppColors.background;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('MyApp: Applying SystemUIOverlayStyle (post-frame), isDarkMode: $isDarkMode');
      _updateSystemUIOverlayStyle(isDarkMode);
    });

    final lightTheme = ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: appBarBackgroundColor,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.black, fontSize: 14),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
          elevation: WidgetStatePropertyAll(4),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
        bodyLarge: TextStyle(color: Colors.black),
        labelLarge: TextStyle(color: Colors.black),
      ),
    );

    final darkTheme = ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: appBarBackgroundColor,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        color: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.white, fontSize: 14),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.grey),
          elevation: WidgetStatePropertyAll(4),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        labelLarge: TextStyle(color: Colors.white),
      ),
    );

    return AnimatedTheme(
      data: Theme.of(context),
      duration: const Duration(milliseconds: 300),
      child: MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeProvider.themeMode,
        locale: Provider.of<LanguageProvider>(context).locale,
        supportedLocales: const [
          Locale('vi'),
          Locale('en'),
          Locale('zh'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: codeProvider.isLoggedIn ? '/navigation' : '/sign-in',
        routes: {
          '/sign-in': (context) => const SignInPage(),
          '/navigation': (context) => const NavigationRailPage(),
          '/pe-system': (context) => const PESystemScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  bool _getIsDarkMode(ThemeProvider themeProvider, BuildContext context) {
    if (themeProvider.themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    } else {
      return themeProvider.themeMode == ThemeMode.dark;
    }
  }

  void _updateSystemUIOverlayStyle(bool isDarkMode) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode ? Colors.grey[900] : AppColors.background,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDarkMode ? Colors.grey[900] : AppColors.background,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }
}