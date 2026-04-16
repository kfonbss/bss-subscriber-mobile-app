import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfDownloadService {
  Future<File> downloadToCache(String url) async {
    final token = await PreferenceUtils.getAccessToken();

    final headers = {
      'accept': 'application/pdf',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load PDF: ${response.statusCode}');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice_preview.pdf');

    // Remove stale cached file before writing so only one copy exists at a time
    if (await file.exists()) await file.delete();

    return file.writeAsBytes(response.bodyBytes);
  }

  Future<String> saveToDownloads(File file) async {
    final dir = await _resolveDownloadsDirectory();

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final newFile = File(
      '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await newFile.writeAsBytes(await file.readAsBytes());
    return newFile.path;
  }

  /// Returns the appropriate downloads directory for the current platform.
  /// On Android 9 and below, requests legacy storage permission.
  Future<Directory> _resolveDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Android 10+ (OS version 10, API 29+): scoped storage — no runtime
      // permission needed. Android 9 and below (OS version < 10) require it.
      if (_androidOsVersion() < 10) {
        await Permission.storage.request();
      }

      // path_provider's getExternalStorageDirectories returns the
      // app-specific directory, but for a user-visible Downloads folder
      // we resolve it dynamically to avoid hardcoding.
      final dirs = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (dirs != null && dirs.isNotEmpty) return dirs.first;

      // Fallback: app-specific external storage
      return (await getExternalStorageDirectory()) ??
          await getTemporaryDirectory();
    }

    // iOS / other: use application documents directory
    return getApplicationDocumentsDirectory();
  }

  // Returns the Android OS release version (e.g. 9 for Android 9, 10 for Android 10).
  // Platform.operatingSystemVersion returns strings like "9", "9 REL", "12", etc.
  // We extract only the leading digits to handle any suffix safely.
  int _androidOsVersion() {
    if (!Platform.isAndroid) return 0;
    try {
      final match = RegExp(r'^\d+').firstMatch(Platform.operatingSystemVersion);
      return match != null ? int.parse(match.group(0)!) : 10;
    } catch (_) {
      return 10; // assume Android 10+ on parse failure
    }
  }
}
