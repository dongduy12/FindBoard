import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../../../../core/constants/colors.dart';
import '../providers/code_provider.dart';
import '../widgets/code_item.dart';
import 'qr_scan_page.dart';
import '../../../../core/localization/app_localizations.dart';

class PESystemScreen extends StatefulWidget {
  const PESystemScreen({super.key});

  @override
  _PESystemScreenState createState() => _PESystemScreenState();
}

class _PESystemScreenState extends State<PESystemScreen> {
  final TextEditingController _scannedCodeController = TextEditingController();
  final FocusNode _scanInputFocus = FocusNode();
  late AudioPlayer _audioPlayer;
  bool _hasFocus = false;
  bool _isFromQR = false;
  bool _isKeyboardEnable = false;//Kiem soat trang thai keyboard

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    print('Initialized _scanInputFocus: ${_scanInputFocus.hashCode}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final codeProvider = Provider.of<CodeProvider>(context, listen: false);
        codeProvider.fetchSearchList();//Lay danh sach tu database

        //hien thi ban phim khi moi load vao he thong
        // Future.delayed(const Duration(milliseconds: 100), () {
        //   FocusScope.of(context).requestFocus(_scanInputFocus);
        //   print('Initial focus requested for _scanInputFocus');
        // });
      }
    });
  }

  Future<void> _handleScanCode(String code, {bool isFromQR = false}) async {
    final provider = Provider.of<CodeProvider>(context, listen: false);
    if (code.isEmpty) {
      if (mounted && !isFromQR) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          //FocusScope.of(context).requestFocus(_scanInputFocus);
          print('Empty code, cleared TextField, focused _scanInputFocus');
          _scannedCodeController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _scannedCodeController.text.length,
          );
        });
      }
      return;
    }
    print('Handling code: $code, isFromQR: $isFromQR');
    final isFound = await provider.handleScanCode(
      code,
      provider.selectedSearchListIndex != null
          ? int.parse(provider.searchLists[provider.selectedSearchListIndex!].id)
          : null,
    );
    print('isFound: $isFound, error: ${provider.error}');

    //Kích hoạt âm thanh
    if (isFound) {
      _audioPlayer.play(AssetSource('sounds/iphone.mp3')).catchError((e) {
        print('Audio error: $e');
        return null;

      });

      //Kích hoạt rung
      if(await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500); //Rung trong 500ms
      }else {
        print('Device does not support vibration');
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.green,
            content: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Tìm thấy!',
                  style: TextStyle(
                    //color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            print('Dialog closed');
            _scannedCodeController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _scannedCodeController.text.length,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (!_isKeyboardEnable) {
                  FocusScope.of(context).unfocus(); // Ngăn bàn phím ảo bật
                }
                FocusScope.of(context).requestFocus(_scanInputFocus);
                print('Focused TextField after dialog');
              }
            });
          }
        });
      }
    } else {
      if (mounted) {
        _scannedCodeController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _scannedCodeController.text.length,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (!_isKeyboardEnable) {
              FocusScope.of(context).unfocus(); // Ngăn bàn phím ảo bật
            }
            FocusScope.of(context).requestFocus(_scanInputFocus);
            print('Focused TextField after not found');
          }
        });
      }
    }
    _isFromQR = false;
  }

  void _openQRScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScanPage(
          onCodeScanned: (code) {
            if (mounted) {
              _scannedCodeController.text = code;
              _isFromQR = true;
              FocusScope.of(context).unfocus();
              print('QR code set to TextField: $code');
              _handleScanCode(code, isFromQR: true);
            }
          },
        ),
      ),
    );
  }

  void _syncSearchLists() async {
    final provider = Provider.of<CodeProvider>(context, listen: false);
    await provider.fetchSearchList();
    print('Sync search lists triggered');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'search')),
        //backgroundColor: const Color(0xFF0055A5),
        elevation: 0,
      ),
      body: SafeArea(
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SELECT LIST',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Consumer<CodeProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const CircularProgressIndicator();
                          } else if (provider.searchLists.isNotEmpty) {
                            return ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: DropdownButton<int>(
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(12),
                                value: provider.selectedSearchListIndex,
                                hint: const Text('Chọn danh sách'),
                                items: provider.searchLists
                                    .asMap()
                                    .entries
                                    .map((entry) => DropdownMenuItem<int>(
                                  value: entry.key,
                                  child: Text(
                                    entry.value.listName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    print('Dropdown changed to: $value');
                                    provider.setSelectedSearchListIndex(value);
                                  }
                                },
                              ),
                            );
                          } else {
                            return const Text('Không có danh sách');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.sync,
                          //color: AppColors.primary,
                        ),
                        onPressed: _syncSearchLists,
                        tooltip: 'Đồng bộ danh sách',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Consumer<CodeProvider>(
                    builder: (context, provider, child) {
                      if (provider.codeList.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                'Danh sách (${provider.foundCount}/${provider.totalCount})',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Không có SN nào để hiển thị! Vui lòng chọn danh sách!',
                              //style: TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Consumer<CodeProvider>(
                  builder: (context, provider, child) {
                    if (provider.codeList.isNotEmpty) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final code = provider.codeList[index];
                            return CodeItem(
                              code: code,
                              isFound: provider.foundCodes.contains(code.serialNumber),
                            );
                          },
                          childCount: provider.codeList.length,
                        ),
                      );
                    } else {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                  },
                ),
              ],
            ),
          ),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Serial Number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _scannedCodeController,
                          focusNode: _scanInputFocus,
                          decoration: InputDecoration(
                            hintText: 'Nhập Serial Number...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            //fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onSubmitted: (value) => _handleScanCode(value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          //color: AppColors.primary,
                        ),
                        onPressed: _openQRScanner,
                        tooltip: 'Quét mã QR',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  @override
  void dispose() {
    print('Disposing _scanInputFocus: ${_scanInputFocus.hashCode}');
    _scannedCodeController.dispose();
    _scanInputFocus.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}