import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/constant/constant_colors.dart';
import '../../core/constant/constant_dimensions.dart';

class CommonFileUploader extends StatefulWidget {
  final String label;
  final String hintText;
  final List<PlatformFile> selectedFiles;

  const CommonFileUploader({
    super.key,
    required this.label,
    required this.hintText,
    required this.selectedFiles,
  });

  @override
  State<CommonFileUploader> createState() => _CommonFileUploaderState();
}

class _CommonFileUploaderState extends State<CommonFileUploader> {
  final ValueNotifier<int> _fileListCountNotifier = ValueNotifier<int>(0);


  @override
  void dispose() {
    _fileListCountNotifier.dispose();
    super.dispose();
  }

  _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf', 'png', 'doc','docx'],
    );
    if (result != null) {
      for (var file in result.files) {
        widget.selectedFiles.add(file);
      }
      _fileListCountNotifier.value = widget.selectedFiles.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.kTextFiledLabelColor,
          ),
        ),
        SizedBox(
          height: AppDimensions.kTextFieldHeight,
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColor.kTextFiledBorderColor,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            spacing: 15,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF4E6ED),
                                  borderRadius: BorderRadius.circular(
                                    6.0,
                                  ), // Uniform rounded corners
                                ),
                                child: Icon(
                                  Icons.cloud_upload_outlined,
                                  color: AppColor.kPrimaryColor,
                                  size: 20,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.hintText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: _fileListCountNotifier,
                          builder: (context, files, child) {
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.selectedFiles.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5.0,bottom: 5.0,left: 5.0),
                                  child: Stack(
                                    children: [
                                      widget.selectedFiles[index].extension ==
                                          'jpg' ||
                                          widget.selectedFiles[index].extension ==
                                              'jpeg' ||
                                          widget.selectedFiles[index].extension ==
                                              'png'
                                          ? Image.file(
                                        File(widget.selectedFiles[index].path!),
                                        fit: BoxFit.cover,
                                      )
                                          : Image.asset(
                                        'assets/images/document.png',
                                        fit: BoxFit.cover,
                                      )
                                      ,
                                      Positioned(
                                        left: 0,
                                        bottom: 0,
                                        top:0,
                                        right:0,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: Icon(Icons.cancel),
                                          iconSize: 20.0,
                                          color: AppColor.kFailedRed,
                                          onPressed: () {
                                            widget.selectedFiles.removeAt(index);
                                            _fileListCountNotifier.value =
                                                widget.selectedFiles.length;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectFile(),
                child: Container(
                  height: double.infinity,
                  width: AppDimensions.kTextFieldHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColor.kTextFiledBorderColor,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.add, color: AppColor.kPrimaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
