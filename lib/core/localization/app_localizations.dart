import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/pe_system/presentation/providers/language_provider.dart';

class AppLocalizations {
  static const _localizedValues = {
    'en': {
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'system': 'System',
      'light': 'Light',
      'dark': 'Dark',
      'english': 'English',
      'vietnamese': 'Vietnamese',
      'chinese': 'Chinese',
    },
    'vi': {
      'darkMode': 'Ch\u1ebf \u0111\u1ed9 t\u1ed1i',
      'language': 'Ng\u00f4n ng\u1eef',
      'system': 'H\u1ec7 th\u1ed1ng',
      'light': 'S\u00e1ng',
      'dark': 'T\u1ed1i',
      'english': 'Ti\u1ebfng Anh',
      'vietnamese': 'Ti\u1ebfng Vi\u1ec7t',
      'chinese': 'Ti\u1ebfng Trung',
    },
    'zh': {
      'darkMode': '\u6697\u9ed1\u6a21\u5f0f',
      'language': '\u8bed\u8a00',
      'system': '\u7cfb\u7edf',
      'light': '\u4eae',
      'dark': '\u6697',
      'english': '\u82f1\u8bed',
      'vietnamese': '\u8d8a\u5357\u8bed',
      'chinese': '\u4e2d\u6587',
    }
  };

  static String of(BuildContext context, String key) {
    final provider = Provider.of<LanguageProvider>(context);
    final code = provider.locale.languageCode;
    return _localizedValues[code]?[key] ?? key;
  }
}
