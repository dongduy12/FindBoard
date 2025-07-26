import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:mobile_app/core/constants/colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/code_provider.dart';

class RetestScreen extends StatefulWidget {
  const RetestScreen({super.key});

  @override
  _RetestScreenState createState() => _RetestScreenState();
}

class _RetestScreenState extends State<RetestScreen> {
  QRViewController? _controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  bool _isScanning = false;
  bool _isManualInput = true; // Mặc định bật chế độ nhập tay (Toggle tắt)
  final TextEditingController _serialNumberController = TextEditingController();

  @override
  void dispose() {
    _controller?.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        final provider = Provider.of<CodeProvider>(context, listen: false);
        provider.updateScannedSerialNumber(scanData.code!);
        setState(() {
          _isScanning = false;
        });
        controller.stopCamera();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CodeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context, 'retest')),
            //backgroundColor: const Color(0xFF0055A5),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(14.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Toggle giữa quét QR và nhập tay
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context, 'qrScan'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Switch(
                        value: !_isManualInput, // Ngược lại để "Quét QR" bật khi Switch ON
                        onChanged: (value) async {
                          setState(() {
                            _isManualInput = !value;
                            _isScanning = value; // Bật quét QR ngay khi Switch ON
                            if (value) {
                              _controller?.resumeCamera();
                            } else {
                              _controller?.stopCamera();
                              _serialNumberController.clear();
                              provider.updateScannedSerialNumber('');
                            }
                          });
                          if (value) {
                            await provider.requestCameraPermission();
                          }
                        },
                        activeColor: AppColors.primary,
                        activeTrackColor: Colors.green.withOpacity(0.5),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.withOpacity(0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Hiển thị giao diện tương ứng
                  if (_isManualInput) ...[
                    TextField(
                      controller: _serialNumberController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context, 'serialNumber'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        provider.updateScannedSerialNumber(value.trim());
                      },
                    ),
                  ] else ...[
                    if (_isScanning) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: QRView(
                          key: _qrKey,
                          onQRViewCreated: _onQRViewCreated,
                          overlay: QrScannerOverlayShape(
                            borderColor: AppColors.primary,
                            borderRadius: 10,
                            borderLength: 30,
                            borderWidth: 10,
                            cutOutSize: 250,
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (provider.scannedSerialNumber != null &&
                      provider.scannedSerialNumber!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      "${AppLocalizations.of(context, 'serialNumber')}: ${provider.scannedSerialNumber}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context, 'selectStatus'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: provider.retestResult,
                      items: ['Pass', 'Fail                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          '].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        provider.setRetestResult(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context, 'results'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        provider.setNotes(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await provider.pickImage();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: Text(AppLocalizations.of(context, 'importPhoto')),
                    ),
                    if (provider.retestImage != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          provider.retestImage!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    provider.isSubmittingRetest
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          print('Submit Retest button pressed!');
                          print(
                              'Before submit: serialNumber = ${provider.scannedSerialNumber}, result=${provider.retestResult}, image=${provider.retestImage?.path}');
                          await provider.submitRetest();
                          print('After submit: error=${provider.retestError}');
                          if (provider.retestError == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context, 'retestSuccess'))),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: Text(AppLocalizations.of(context, 'submit')),
                      ),
                    ),
                    if (provider.retestError != null) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          provider.retestError!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}