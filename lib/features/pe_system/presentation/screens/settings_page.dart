//Giao diện với radio buttons để chọn theme.
// UI: Hiển thị danh sách RadioListTile để chọn ThemeMode (System, Light, Dark).
// Provider: Lắng nghe ThemeProvider để cập nhật trạng thái radio buttons và gọi setThemeMode khi người dùng chọn.
// AppBar: Đồng bộ màu với theme (AppColors.background hoặc Colors.grey[900]).
// Log: Thêm print để debug khi theme thay đổi.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.dark_mode_outlined),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context, 'darkMode'),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        child: DropdownButton<ThemeMode>(
                          value: themeProvider.themeMode,
                          dropdownColor: isDarkMode ? Colors.grey[700] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                          underline: const SizedBox(),
                          iconEnabledColor: isDarkMode ? Colors.white : Colors.black87,
                          items: [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text(AppLocalizations.of(context, 'system')),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text(AppLocalizations.of(context, 'light')),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text(AppLocalizations.of(context, 'dark')),
                            ),
                          ],
                          onChanged: (ThemeMode? value) {
                            if (value != null) {
                              themeProvider.setThemeMode(value);
                              print('Theme changed to: $value');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.language),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context, 'language'),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        child: DropdownButton<Locale>(
                          value: languageProvider.locale,
                          dropdownColor: isDarkMode ? Colors.grey[700] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                          underline: const SizedBox(),
                          iconEnabledColor: isDarkMode ? Colors.white : Colors.black87,
                          items: [
                            DropdownMenuItem(
                              value: const Locale('vi'),
                              child: Text(AppLocalizations.of(context, 'vietnamese')),
                            ),
                            DropdownMenuItem(
                              value: const Locale('en'),
                              child: Text(AppLocalizations.of(context, 'english')),
                            ),
                            DropdownMenuItem(
                              value: const Locale('zh'),
                              child: Text(AppLocalizations.of(context, 'chinese')),
                            ),
                          ],
                          onChanged: (Locale? value) {
                            if (value != null) {
                              languageProvider.setLocale(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
