import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';

class PdfDownloadService {
  // ── Download to cache (for viewing) ───────────────────────────────────────
  Future<File> downloadToCache(String url) async {
    final uri = Uri.parse(url);
    final token = await PreferenceUtils.getAccessToken();
    final isPresignedUrl = uri.queryParameters.containsKey('X-Amz-Algorithm');

    http.Response response;

    if (isPresignedUrl) {
      response = await http.get(uri, headers: {'accept': '*/*'});
    } else {
      final headers = {
        'accept': 'application/pdf',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      response = await http.get(uri, headers: headers);

      // fallback
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

  // ── Save cached File to public Downloads ──────────────────────────────────
  Future<String> saveToDownloads(File file) async {
    final bytes = await file.readAsBytes();
    final fileName = 'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
    return _saveBytes(bytes, fileName);
  }

  // ── Download from URL to public Downloads ─────────────────────────────────
  Future<String> downloadToDownloads(String url) async {
    final uri = Uri.parse(url);
    final token = await PreferenceUtils.getAccessToken();
    final tenantId = await PreferenceUtils.getTenantId();

    final response = await http.get(
      uri,
      headers: {
        'accept': 'application/pdf',
        'Authorization': 'Bearer $token',
        'X-Tenant-ID': tenantId ?? '',
      },
    );

    debugPrint('📥 Status: ${response.statusCode}');
    debugPrint('📥 Bytes: ${response.bodyBytes.length}');

    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF: HTTP ${response.statusCode}');
    }

    _validatePdf(response.bodyBytes);

    final fileName = 'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
    return _saveBytes(response.bodyBytes, fileName);
  }

  // ── Save bytes using saver_gallery ────────────────────────────────────────
  Future<String> _saveBytes(List<int> bytes, String fileName) async {
    if (Platform.isAndroid) {
      // 👇 request permission explicitly
      final status = await Permission.manageExternalStorage.request();
      debugPrint('📋 Manage storage: $status');

      final writeStatus = await Permission.storage.request();
      debugPrint('📋 Write storage: $writeStatus');

      // try all possible paths
      final paths = [
        '/storage/emulated/0/Download/$fileName',
        '/sdcard/Download/$fileName',
      ];

      for (final path in paths) {
        try {
          final file = File(path);
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes);
          debugPrint('✅ Saved to: $path');
          return path;
        } catch (e) {
          debugPrint('⚠️ Failed path $path: $e');
          continue;
        }
      }

      // last fallback — external app directory (visible in file manager)
      final extDirs = await getExternalStorageDirectories();
      if (extDirs != null && extDirs.isNotEmpty) {
        final file = File('${extDirs.first.path}/$fileName');
        await file.writeAsBytes(bytes);
        debugPrint('✅ Saved to external: ${file.path}');
        return file.path;
      }
    }

    // iOS / fallback
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  // ── Validate PDF bytes ────────────────────────────────────────────────────
  void _validatePdf(List<int> bytes) {
    if (bytes.length < 4) {
      throw Exception('Invalid PDF: file too small');
    }
    final header = String.fromCharCodes(bytes.take(4));
    if (!header.startsWith('%PDF')) {
      debugPrint('❌ Not a PDF — header: $header');
      debugPrint('❌ Body: ${String.fromCharCodes(bytes.take(200))}');
      throw Exception('Response is not a valid PDF');
    }
    debugPrint('✅ Valid PDF confirmed');
  }
}
