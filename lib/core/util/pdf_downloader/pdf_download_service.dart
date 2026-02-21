import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfDownloadService {
  Future<File> downloadToCache(String url) async {
    // Get access token for authentication
    final token = await PreferenceUtils.getAccessToken();

    // Prepare headers with authentication and accept PDF header
    final headers = {
      'accept': 'application/pdf',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load PDF: ${response.statusCode}');
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    return file.writeAsBytes(response.bodyBytes);
  }

  Future<String> saveToDownloads(File file) async {
    await Permission.storage.request();

    final dir = Directory('/storage/emulated/0/Download');
    final newFile = File(
      '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await newFile.writeAsBytes(await file.readAsBytes());
    return newFile.path;
  }
}
