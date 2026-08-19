import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/language_pack.dart';

class FileService {
  static final FileService instance = FileService._();
  FileService._();

  Future<LanguagePack?> openPackFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'xlang'],
      dialogTitle: 'Открыть языковой пакет Xaneo',
    );

    if (result.isEmpty) return null;

    final path = result.single.path;
    if (path == null) return null;

    final file = File(path);
    final content = await file.readAsString();
    final jsonMap = jsonDecode(content) as Map<String, dynamic>;
    return LanguagePack.fromJson(jsonMap);
  }

  Future<String?> savePackToFile(LanguagePack pack, {String? targetPath}) async {
    final jsonStr = pack.toFormattedJson();
    final bytes = utf8.encode(jsonStr);

    if (targetPath != null) {
      final file = File(targetPath);
      await file.writeAsString(jsonStr);
      return targetPath;
    }

    final outputUri = await FilePicker.saveFile(
      dialogTitle: 'Сохранить языковой пакет',
      fileName: '${pack.locale.replaceAll('/', '_')}_lang.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );

    if (outputUri == null) return null;

    final outputPath = outputUri.toFilePath();
    final file = File(outputPath);
    await file.writeAsString(jsonStr);
    return outputPath;
  }

  Future<File> exportToTempFile(LanguagePack pack) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${pack.locale}_lang.json');
    await file.writeAsString(pack.toFormattedJson());
    return file;
  }
}
