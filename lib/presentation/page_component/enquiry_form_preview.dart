import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/constant_dimensions.dart';

class EnquiryFormPreview extends StatelessWidget {
  final String heading;
  final Map<String, dynamic> map;

  const EnquiryFormPreview({
    super.key,
    required this.map,
    required this.heading,
  });

  // String capitalize(String title) {
  //   return title
  //       .split('_')
  //       .map((word) {
  //         if (word.isEmpty) {
  //           return '';
  //         }
  //         return word[0].toUpperCase() + word.substring(1).toLowerCase();
  //       })
  //       .join(' ');
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 10),
            color: AppColor.kYellowBackground,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              heading,
              style: TextStyle(
                color: AppColor.kBlackHeadingColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  map.entries
                      .map(
                        (item) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            Text(
                              // capitalize(item.key),
                              item.key,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: AppColor.kBlackHeadingColor,
                              ),
                            ),
                            item.value is String
                                ? Text(
                                  item.value,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                )
                                : item.value is List<PlatformFile>
                                ? SizedBox(
                                  height: AppDimensions.kTextFieldHeight,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: item.value.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                        child: item.value[index].extension ==
                                                    'jpg' ||
                                                item.value[index].extension ==
                                                    'jpeg' ||
                                                item.value[index].extension ==
                                                    'png'
                                            ? Image.file(
                                              File(item.value[index].path!),
                                              fit: BoxFit.cover,
                                            )
                                            : Image.asset(
                                              'assets/images/document.png',
                                              fit: BoxFit.cover,
                                            ),
                                      );
                                    },
                                  ),
                                )
                                : item.value is List<String>
                                ? ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: item.value.length,
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    return Text(
                                      item.value[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    );
                                  },
                                )
                                : Container(),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
