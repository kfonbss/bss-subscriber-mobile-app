import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kfon_subscriber/core/constant/constant.dart';

class LoginBackground extends StatelessWidget {
  final String heading;
  final Widget child;
  final double height;
  final double bottomMargin;

  const LoginBackground({
    super.key,
    required this.heading,
    required this.height,
    required this.bottomMargin,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/white_doodle.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/dark_doodle.png'),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(100.0),
                    topRight: Radius.circular(100.0),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: SvgPicture.asset(
                    'assets/images/login_page_bottom_image.svg',
                    height: 100,
                    fit: BoxFit.cover, // Optional: apply a color filter
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomMargin,
          child: SizedBox(
            height: height,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Adjust the radius as needed
              ),
              margin: const EdgeInsets.only(left: 15,right: 15),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Text(
                      heading,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20,),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
