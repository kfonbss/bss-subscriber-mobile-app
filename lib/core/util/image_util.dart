import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
class ImageUtil {

  Future<String> convertImageToBase64(PlatformFile pickedFile) async {
    File imageFile = File(pickedFile.path!);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return 'Base64 Image: $base64Image';
  }
}
