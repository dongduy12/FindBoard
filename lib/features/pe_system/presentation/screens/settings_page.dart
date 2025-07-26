//Giao diện với radio buttons để chọn theme.
// UI: Hiển thị danh sách RadioListTile để chọn ThemeMode (System, Light, Dark).
// Provider: Lắng nghe ThemeProvider để cập nhật trạng thái radio buttons và gọi setThemeMode khi người dùng chọn.
// AppBar: Đồng bộ màu với theme (AppColors.background hoặc Colors.grey[900]).
// Log: Thêm print để debug khi theme thay đổi.


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                          const Text(
                            'Chế độ tối',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      DropdownButton<ThemeMode>(
                        value: themeProvider.themeMode,
                        dropdownColor: isDarkMode ? Colors.grey[700] : Colors.white,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                        underline: const SizedBox(),
                        iconEnabledColor: isDarkMode ? Colors.white : Colors.black87,
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                            print('Theme changed to: $value');
                          }
                        },
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