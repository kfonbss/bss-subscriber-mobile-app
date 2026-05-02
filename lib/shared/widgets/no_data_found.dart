import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({super.key, required this.errorMessage});
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/filler.png',
                height: constraints.maxHeight * 0.5,
              ),
              Text(
                errorMessage,
                style: TextStyle(color: AppColor.kTextSecondary, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
