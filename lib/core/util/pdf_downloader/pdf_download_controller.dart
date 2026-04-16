import 'dart:io';

import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_download_service.dart';
import 'package:share_plus/share_plus.dart';

class PdfDownloadController {
  final PdfDownloadService _service = PdfDownloadService();

  Future<File> loadPdf(String url) {
    return _service.downloadToCache(url);
  }

  void sharePdf(File file) {
    Share.shareXFiles([XFile(file.path)], text: 'Invoice PDF');
  }

  Future<String> downloadPdf(File file) async {
    return _service.saveToDownloads(file);
  }
}
