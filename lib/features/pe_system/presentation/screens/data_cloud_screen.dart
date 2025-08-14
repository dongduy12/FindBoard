import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dataCloud_provider.dart';
import '../widgets/data_cloud_item.dart';
import '../../../../core/localization/app_localizations.dart';

class DataCloudScreen extends StatefulWidget {
  const DataCloudScreen({super.key});

  @override
  _DataCloudScreenState createState() => _DataCloudScreenState();
}

class _DataCloudScreenState extends State<DataCloudScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _folderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gọi API khi màn hình được mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatacloudProvider>(context, listen: false).fetchDataCloud();
    });
  }


  void _showContextMenu(BuildContext context, DataCloudItem item, Offset position) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 100, 100),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'download',
          child: ListTile(
            leading: const Icon(Icons.download),
            title: Text(AppLocalizations.of(context, 'download')),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: const Icon(Icons.delete),
            title: Text(AppLocalizations.of(context, 'delete')),
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleContextAction(value, item);
      }
    });
  }

  void _handleContextAction(String action, DataCloudItem item) async {
    final provider = Provider.of<DatacloudProvider>(context, listen: false);
    if (action == 'download') {
      // Tạo URL download
      final url = item.type == 'File'
          ? 'http://10.220.130.119:8000/api/data/download-file?path=${Uri.encodeComponent(item.path)}'
          : 'http://10.220.130.119:8000/api/data/download-folder?path=${Uri.encodeComponent(item.path)}';
      // Hiện tại chỉ in URL, bạn cần package như url_launcher để mở URL
      print('Downloading: $url');
      // Để tải file thực sự, cần thêm package như flutter_downloader
    } else if (action == 'delete') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context, 'confirmDelete')),
          content: const Text('This action cannot be undone!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context, 'cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await provider.deleteItem(item.path, item.type);
                if (provider.dataCloudError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.dataCloudError!)),
                  );
                }
              },
              child: Text(AppLocalizations.of(context, 'confirmDelete')),
            ),
          ],
        ),
      );
    }
  }

  void _pickFiles({bool isFolder = false}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: isFolder ? FileType.any : FileType.any,
      allowCompression: false,
    );
    if (result != null) {
      final files = result.paths.map((path) => File(path!)).toList();
      await Provider.of<DatacloudProvider>(context, listen: false).uploadFiles(files, isFolder: isFolder);
      if (Provider.of<DatacloudProvider>(context, listen: false).dataCloudError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Provider.of<DatacloudProvider>(context, listen: false).dataCloudError!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatacloudProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context, 'dataCloud')),
            //backgroundColor: const Color(0xFF0055A5),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(AppLocalizations.of(context, 'search')),
                      content: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context, 'enterKeyword')),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            provider.searchDataCloud(_searchController.text);
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context, 'search')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.dataCloudResponse?.currentPath ?? 'Loading...'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: provider.pathHistory.length > 1
                          ? () {
                        provider.pathHistory.removeLast();
                        provider.fetchDataCloud(path: provider.pathHistory.last);
                      }: null,
                      color: provider.pathHistory.length > 1 ? Colors.blue : Colors.grey,
                      tooltip: AppLocalizations.of(context, 'back'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: provider.isLoadingDataCloud
                      ? const Center(child: CircularProgressIndicator())
                      : provider.dataCloudError != null
                      ? Center(child: Text(provider.dataCloudError!, style: const TextStyle(color: Colors.red)))
                      : provider.dataCloudResponse == null || provider.dataCloudResponse!.items.isEmpty
                      ? Center(child: Text(AppLocalizations.of(context, 'noItemsFound')))
                      : ListView.builder(
                    itemCount: provider.dataCloudResponse!.items.length,
                    itemBuilder: (context, index) {
                      final item = provider.dataCloudResponse!.items[index];
                      return GestureDetector(
                        onSecondaryTapDown: (details) => _showContextMenu(context, item, details.globalPosition),
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Icon(
                              item.type == 'Folder' ? Icons.folder : Icons.insert_drive_file,
                              color: item.type == 'Folder' ? Colors.orange : Colors.blue,
                            ),
                            title: Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            subtitle: Text(item.path),
                            onTap: () {
                              if (item.type == 'Folder') {
                                provider.fetchDataCloud(path: item.path);
                              } else {
                                print('Tapped on file: ${item.name}');
                              }
                            },
                          ),
                        ),
                      );
                    },
                  )
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickFiles(),
                      icon: const Icon(Icons.upload_file),
                      label: Text(AppLocalizations.of(context, 'uploadFile')),
                    ),
                    // ElevatedButton.icon(
                    //   onPressed: () => _pickFiles(isFolder: true),
                    //   icon: const Icon(Icons.folder),
                    //   label: const Text('Upload Folder'),
                    // ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(AppLocalizations.of(context, 'newFolder')),
                            content: TextField(
                              controller: _folderNameController,
                              decoration: const InputDecoration(labelText: 'Folder Name'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Provider.of<DatacloudProvider>(context, listen: false).createFolder(_folderNameController.text);
                                  Navigator.pop(context);
                                  _folderNameController.clear();
                                },
                                child: Text(AppLocalizations.of(context, 'create')),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.create_new_folder),
                      label: Text(AppLocalizations.of(context, 'newFolder')),
                    ),
                  ],
                )
              ],
            )
          ),
        );
      },
    );
  }
}