part of 'open_file_manager.dart';

class AndroidConfig {
  final FolderType folderType;

  AndroidConfig({required this.folderType});
}

class IosConfig {
  final String subFolderPath;

  IosConfig({required this.subFolderPath});
}

enum FolderType { recent, download }
