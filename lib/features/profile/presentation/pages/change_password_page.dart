import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_password_text_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_color_button.dart';

class ChangePasswordPage extends StatefulWidget {
  final bool isBssRequest;

  const ChangePasswordPage({super.key, required this.isBssRequest});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPassTextEditingController =
      TextEditingController();
  final TextEditingController newPassTextEditingController =
      TextEditingController();
  final TextEditingController conformPassTextEditingController =
      TextEditingController();

  @override
  void dispose() {
    currentPassTextEditingController.dispose();
    newPassTextEditingController.dispose();
    conformPassTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Security Settings',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 40,
          children: [
            Text(
              widget.isBssRequest
                  ? 'Change BSS Portal Password'
                  : 'Change Internet Password',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
                color: Colors.black,
                height: 1.30,
              ),
            ),
            Column(
              spacing: 16,
              children: [
                CommonPasswordTextField(
                  textEditingController: currentPassTextEditingController,
                  hintText: 'Enter your password',
                  heading: 'Current Password',
                ),
                CommonPasswordTextField(
                  textEditingController: currentPassTextEditingController,
                  hintText: 'Enter new password',
                  heading: 'New Password',
                ),

                CommonPasswordTextField(
                  textEditingController: currentPassTextEditingController,
                  hintText: 'Confirm New Password',
                  heading: 'Confirm New Password',
                ),
              ],
            ),
            Column(
              spacing: 16,
              children: [
                PrimaryColorButton(
                  label: 'Update Password',
                  borderRadius: 10,
                  onClicked: () => _passwordChanged(),
                  isLoading: false,
                ),
                Center(
                  child: Text(
                    'Forgot password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF67697A),
                      fontSize: 14,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.60,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _passwordChanged() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Illustration_password.png',
                fit: BoxFit.cover,
                height: 140.h,
                width: 140.w,
              ),
              SizedBox(height: 24,),
              Text(
                'Password Updated\n Successfully 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,

                ),
              ),

              SizedBox(height: 12,),
              Text(
                "Your password has been changed. You'll be redirected to Security Settings.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500,
                ),
              ),

              SizedBox(height: 20,),
              PrimaryColorButton(
                borderRadius: 10,
                isLoading: false,
                label: 'Login Now',
                onClicked: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
