import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/code_entity.dart';
import '../providers/code_provider.dart';

class CodeItem extends StatelessWidget {
  final CodeEntity code;
  final bool isFound;

  const CodeItem({
    super.key,
    required this.code,
    required this.isFound,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CodeProvider>(context, listen: false);
    final isRecentlyScanned = provider.recentlyScannedCodes.contains(code.serialNumber);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: isFound ? AppColors.foundCode : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  code.foundOrder != null
                      ? '${code.foundOrder}. ${code.serialNumber}'
                      : code.serialNumber,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isRecentlyScanned
                        ? Colors.red // Màu đỏ cho SN vừa quét
                        : (code.foundOrder != null
                        ? Colors.yellow[700] // Vàng cho SN tìm thấy trước
                        : (isFound ? AppColors.primary : Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Model: ${code.modelName}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Vị trí: ${code.shelfCode} - C${code.columnNumber} L${code.levelNumber} T${code.trayNumber} P${code.positionInTray}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}