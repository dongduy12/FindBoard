import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/pe_system/presentation/providers/language_provider.dart';
import 'language_converter.dart';

class AppLocalizations {
  static String of(BuildContext context, String key) {
    final provider = Provider.of<LanguageProvider>(context);
    return LanguageConverter.translate(key, provider.locale);
  }
}
