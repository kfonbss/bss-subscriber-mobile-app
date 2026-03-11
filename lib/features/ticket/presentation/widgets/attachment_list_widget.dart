import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class AttachmentListWidget extends StatelessWidget {
  final List<PlatformFile> selectedFiles;
  final Function(PlatformFile) onViewFile;
  final Function(PlatformFile) onDeleteFile;

  const AttachmentListWidget({
    super.key,
    required this.selectedFiles,
    required this.onViewFile,
    required this.onDeleteFile,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedFiles.isEmpty) return const SizedBox.shrink();

    return Column(
      children:
          selectedFiles.map((file) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBCBCB), width: 1),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/document-submit.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      AppColor.kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file.name,
                      style: const TextStyle(
                        color: Color(0xFF262629),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        fontFamily: 'GeneralSans',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => onViewFile(file),
                    child: ImageIcon(
                      const AssetImage('assets/icons/eye.png'),
                      size: 20,
                      color: const Color(0xFF767681),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => onDeleteFile(file),
                    child: SvgPicture.asset(
                      'assets/icons/delete.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF767681),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
