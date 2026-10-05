import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

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
              height: 48.h,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.kBorderGrey, width: 1),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.documentSubmit,
                    width: 24.w,
                    height: 24.h,
                    colorFilter: ColorFilter.mode(
                      AppColor.kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      file.name,
                      style: const TextStyle(
                        color: AppColor.kNearBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        fontFamily: 'GeneralSans',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => onViewFile(file),
                    child: ImageIcon(
                      const AssetImage(AppAssets.eye),
                      size: 20,
                      color: AppColor.kMutedIconGrey,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => onDeleteFile(file),
                    child: SvgPicture.asset(
                      AppAssets.delete,
                      width: 20.w,
                      height: 20.h,
                      colorFilter: const ColorFilter.mode(
                        AppColor.kMutedIconGrey,
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
