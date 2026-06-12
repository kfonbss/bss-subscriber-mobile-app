import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfDownloadService {
  Future<Directory> _resolveDownloadDirectory() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }

    // iOS/macOS/windows/linux fallback.
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/Downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  Future<File> downloadToCache(String url) async {
    final uri = Uri.parse(url);
    final token = await PreferenceUtils.getAccessToken();
    final isPresignedUrl = uri.queryParameters.containsKey('X-Amz-Algorithm');

    http.Response response;

    if (isPresignedUrl) {
      // Pre-signed object-storage URLs are self-authenticated.
      response = await http.get(uri, headers: {'accept': '*/*'});
    } else {
      final headers = {
        'accept': 'application/pdf',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      response = await http.get(uri, headers: headers);

      // Fallback for endpoints that reject auth/strict headers.
      if (response.statusCode != 200) {
        response = await http.get(uri, headers: {'accept': '*/*'});
      }
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load PDF: HTTP ${response.statusCode}');
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    return file.writeAsBytes(response.bodyBytes);
  }

  Future<String> saveToDownloads(File file) async {
    final dir = await _resolveDownloadDirectory();
    final newFile = File(
      '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await newFile.writeAsBytes(await file.readAsBytes());
    return newFile.path;
  }

  Future<String> downloadToDownloads(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: {'accept': '*/*'});

    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF: HTTP ${response.statusCode}');
    }

    final dir = await _resolveDownloadDirectory();
    final newFile = File(
      '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await newFile.writeAsBytes(response.bodyBytes);
    return newFile.path;
  }
}
